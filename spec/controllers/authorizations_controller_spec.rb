# frozen_string_literal: true

require "spec_helper"

module Decidim::Donations::Verification
  describe AuthorizationsController, type: :controller do
    routes { Decidim::Donations::Verification::Engine.routes }

    let(:organization) do
      create(
        :organization,
        available_authorizations: ["donations"]
      )
    end
    let(:current_user) { create(:user, :confirmed, organization: organization) }
    let(:provider) do
      double("provider",
             amount: amount,
             multistep?: multistep,
             amount_in_cents: amount * 100,
             transaction_id: transaction_id,
             gateway: double,
             method: :paypal_express,
             transaction_hash: "some-hash")
    end
    let(:multistep) { true }
    let(:amount) { 12 }
    let(:redirect_url) { "http://example.org/checkout" }
    let(:payment) do
      double("payment",
             success?: success,
             details: { "OrderTotal" => "#{amount}.00" },
             token: "some-token",
             payer_id: "some-payer-id",
             message: "payment message")
    end
    let(:purchase_response) do
      double("purchase_response",
             success?: response_success,
             message: "response message",
             params: { "transaction_id" => transaction_id })
    end
    let(:success) { true }
    let(:response_success) { true }
    let(:transaction_id) { "some-id" }
    let(:params) do
      {
        amount: amount
      }
    end
    let(:minimum_amount) { 3 }
    let(:default_amount) { 7 }
    let(:verification_amount) { 4 }

    before do
      allow(subject).to receive(:provider).and_return(provider)
      allow(provider).to receive(:setup_purchase).and_return(payment)
      allow(provider).to receive(:details_for).and_return(payment)
      allow(provider).to receive(:purchase).and_return(purchase_response)
      allow(provider.gateway).to receive(:redirect_url_for).and_return(redirect_url)

      Decidim::Donations.config.minimum_amount = minimum_amount
      Decidim::Donations.config.verification_amount = verification_amount
      Decidim::Donations.config.default_amount = default_amount

      request.env["decidim.current_organization"] = organization
      sign_in current_user, scope: :user
    end

    context "when requesting a new authorization" do
      it "renders new template" do
        get :new

        expect(subject).to render_template(:new)
      end

      it "changes the amount in helpers" do
        get :new

        expect(Decidim::Donations.verification_amount).to eq(verification_amount)
        expect(controller.send(:checkout_form).minimum_amount).to eq(verification_amount)
      end

      context "when no verification amount specified" do
        let(:verification_amount) { nil }

        it "defaults to minimum_amount" do
          get :new

          expect(Decidim::Donations.verification_amount).to eq(Decidim::Donations.minimum_amount)
          expect(controller.send(:checkout_form).minimum_amount).to eq(minimum_amount)
        end
      end

      context "and user is already verified" do
        let!(:authorization) { create(:authorization, :granted, user: current_user, name: "donations") }

        it "redirects to user donations" do
          get :new

          expect(response).to redirect_to("/donations/user_donations/new")
        end
      end
    end

    context "when creating a new authorization" do
      context "and is multistep" do
        it "redirects to the gateway" do
          post :create, params: params

          expect(response).to redirect_to(redirect_url)
        end

        context "and setup is unsuccesful" do
          let(:success) { false }

          it "redirects to new donation" do
            post :create, params: params

            expect(response).to redirect_to("/donations/authorizations/new")
            expect(flash[:alert]).to include(payment.message)
          end
        end
      end

      context "and is not multistep" do
        let(:multistep) { false }

        it "processes checkout" do
          post :create, params: params

          expect(response).to redirect_to("/authorizations")
          expect(flash[:notice]).to eq("Thanks for your donation! You have been successfully verified!")
        end
      end

      context "and the amount is not correct" do
        let(:amount) { 3 }

        it "shows an error message" do
          post :create, params: params

          expect(response).not_to redirect_to(redirect_url)
          expect(flash[:alert]).to include("amount is incorrect")
        end
      end
    end

    context "when comming from the gateway" do
      it "processes checkout" do
        get :checkout, params: params

        expect(response).to redirect_to("/authorizations")
        expect(flash[:notice]).to eq("Thanks for your donation! You have been successfully verified!")
      end

      context "and purchase goes wrong" do
        before do
          allow(provider).to receive(:purchase).and_raise(Decidim::Donations::PaymentError, purchase_response.message)
        end

        it "returns to new donation" do
          get :checkout, params: params

          expect(response).to redirect_to("/donations/authorizations/new")
          expect(flash[:alert]).to include(purchase_response.message)
        end
      end
    end
  end
end
