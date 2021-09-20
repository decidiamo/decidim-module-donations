# frozen_string_literal: true

require "spec_helper"

module Decidim::Donations
  describe UserDonationsController, type: :controller do
    routes { Decidim::Donations::Engine.routes }

    let(:organization) do
      create(
        :organization,
        available_authorizations: ["donations"]
      )
    end
    let(:user) { create(:user, :confirmed, organization: organization) }
    let!(:donation) { create(:donation, amount: 12_300, user: user) }
    let!(:another_donation) { create(:donation, amount: 45_600) }
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
      sign_in user, scope: :user
    end

    it "lists current donations" do
      get :show

      expect(response).to render_template(:show)
    end

    it "list own donations" do
      get :show

      expect(controller.helpers.donations.all).to include(donation)
    end

    it "do not list others donations" do
      get :show

      expect(controller.helpers.donations.all).not_to include(another_donation)
    end

    context "when making a new donation" do
      it "renders new template" do
        get :new

        expect(subject).to render_template(:new)
      end

      it "changes the amount in helpers and verification_amount is ignored" do
        get :new

        expect(Decidim::Donations.verification_amount).to eq(verification_amount)
        expect(controller.send(:checkout_form).minimum_amount).to eq(minimum_amount)
      end

      context "when no verification amount specified" do
        let(:verification_amount) { nil }

        it "renders theo minimum_amount" do
          get :new

          expect(Decidim::Donations.verification_amount).to eq(Decidim::Donations.minimum_amount)
          expect(controller.send(:checkout_form).minimum_amount).to eq(minimum_amount)
        end
      end
    end

    context "when creating a new donation" do
      context "and is multistep" do
        it "redirects to the gateway" do
          post :create, params: params

          expect(response).to redirect_to(redirect_url)
        end

        context "and setup is unsuccesful" do
          let(:success) { false }

          it "redirects to new donation" do
            post :create, params: params

            expect(response).to redirect_to("/donations/user_donations")
            expect(flash[:alert]).to include(payment.message)
          end
        end
      end

      context "and is not multistep" do
        let(:multistep) { false }

        it "processes checkout" do
          post :create, params: params

          expect(response).to redirect_to("/donations/user_donations")
          expect(flash[:notice]).to eq("Payment processed successfully. You contribution is greatly appreciated!")
        end
      end

      context "and the amount below the verification level" do
        let(:amount) { 3 }

        it "processes the payment" do
          post :create, params: params

          expect(response).to redirect_to(redirect_url)
        end
      end

      context "and the amount is not correct" do
        let(:amount) { 2 }

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

        expect(response).to redirect_to("/donations/user_donations")
        expect(flash[:notice]).to eq("Payment processed successfully. You contribution is greatly appreciated!")
      end

      context "and purchase goes wrong" do
        before do
          allow(provider).to receive(:purchase).and_raise(Decidim::Donations::PaymentError, purchase_response.message)
        end

        it "returns to new donation" do
          get :checkout, params: params

          expect(response).to redirect_to("/donations/user_donations")
          expect(flash[:alert]).to include(purchase_response.message)
        end
      end
    end
  end
end
