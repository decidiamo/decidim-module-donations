# frozen_string_literal: true

require "spec_helper"

module Decidim::Donations
  describe AmountFormCell, type: :cell do
    controller Decidim::Donations::UserDonationsController

    subject { my_cell.call }

    let(:my_cell) { cell("decidim/donations/amount_form", form) }
    let!(:current_user) { create(:user, :confirmed) }
    let(:form) { Decidim::Donations::CheckoutForm.from_params(params).with_context(context) }
    let(:params) do
      {}
    end
    let(:context) do
      {
        process_path: "some-post-process-path"
      }
    end
    let(:multistep) { true }
    let(:amount) { 12 }
    let(:redirect_url) { "http://example.org/checkout" }
    let(:transaction_id) { "some-id" }
    let(:provider) do
      double("provider",
             amount: amount,
             multistep?: multistep,
             amount_in_cents: amount * 100,
             transaction_id: transaction_id,
             gateway: double,
             method: :paypal_express,
             name: "PayPal",
             transaction_hash: "some-hash")
    end

    before do
      allow(my_cell).to receive(:provider).and_return(provider)
      allow(controller).to receive(:current_user).and_return(current_user)
    end

    it "renders the form" do
      expect(subject).to have_css(".checkout-form")
      expect(subject).to have_css(".terms-and-conditions")
      expect(subject).to have_css("input#checkout_amount")
      expect(subject.find("form").native.attributes["action"].to_s).to eq("some-post-process-path")
      expect(subject).to have_content("I want to contribute with:")
      expect(subject).to have_field("checkout[amount]", with: Decidim::Donations.config.default_amount)
      expect(subject).to have_content("Terms and Conditions")
    end

    context "when params are present" do
      let(:params) do
        {
          amount: amount
        }
      end

      it "renders proper amount" do
        expect(subject).to have_field("checkout[amount]", with: amount)
      end
    end

    context "when no terms and conditions" do
      before do
        allow(Decidim::Donations).to receive(:terms_and_conditions).and_return(nil)
      end

      it "renders nothing" do
        expect(subject).not_to have_css(".terms-and-conditions")
        expect(subject).not_to have_content("Terms and Conditions")
      end
    end

    context "when terms and conditions is not a I18n key" do
      before do
        allow(Decidim::Donations).to receive(:terms_and_conditions).and_return("Ducky Lucky")
      end

      it "renders the text" do
        expect(subject).to have_css(".terms-and-conditions")
        expect(subject).to have_content("Ducky Lucky")
      end
    end
  end
end
