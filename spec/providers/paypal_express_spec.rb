# frozen_string_literal: true

require "spec_helper"
require "active_merchant"

module Decidim::Donations::Providers
  describe PaypalExpress do
    subject { described_class.new settings }

    let(:settings) do
      {
        login: "some-login",
        password: "some-password",
        signature: "some-signature"
      }
    end

    it "is multistep" do
      expect(subject.multistep?).to eq(true)
    end

    it "gateway is PaypalExpress" do
      expect(subject.gateway).to be_a(ActiveMerchant::Billing::PaypalExpressGateway)
      expect(subject.method).to eq("paypal_express")
      expect(subject.name).to eq("PayPal")
    end

    context "when settings are defined" do
      before do
        subject.amount = 12
        subject.transaction_id = "some-id"
        subject.order = "some-order"
      end

      it "returns amount in cents" do
        expect(subject.amount_in_cents).to eq(1200)
      end

      it "returns transaction hash" do
        expect(subject.transaction_hash).to eq("paypal_express-some-id")
      end
    end

    context "when processing orders" do
      let(:order) do
        {
          title: "some-title",
          description: "some-description"
        }
      end
      let(:params) do
        {
          amount: amount,
          token: "some-token"
        }
      end
      let(:payment) do
        double(
          success?: success,
          details: { "OrderTotal" => "#{amount}.00" },
          token: "some-token",
          payer_id: "some-payer-id"
        )
      end
      let(:response) do
        double(
          success?: response_success,
          message: "some message",
          params: { "transaction_id" => transaction_id }
        )
      end
      let(:success) { true }
      let(:response_success) { true }
      let(:amount) { 12 }
      let(:transaction_id) { "some-id" }
      let(:purchase) { subject.purchase(order: order, params: params) }

      before do
        allow(subject.gateway).to receive(:setup_purchase).and_return(payment)
        allow(subject.gateway).to receive(:details_for).and_return(payment)
        allow(subject.gateway).to receive(:purchase).and_return(response)
      end

      it "setup step sets the amount" do
        subject.setup_purchase(order: order, params: params)
        expect(subject.amount).to eq(amount)
      end

      it "purchase step sets the amount and transaction" do
        purchase
        expect(subject.amount).to eq(amount)
        expect(subject.transaction_id).to eq(transaction_id)
      end

      context "when unsuccessful payment" do
        let(:success) { false }

        it "raises payment error" do
          expect { purchase }.to raise_error(Decidim::Donations::PaymentError)
        end
      end

      context "when unsuccessful response" do
        let(:response_success) { false }

        it "raises payment error" do
          expect { purchase }.to raise_error(Decidim::Donations::PaymentError)
        end
      end
    end
  end
end
