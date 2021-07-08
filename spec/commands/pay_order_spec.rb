# frozen_string_literal: true

require "spec_helper"

module Decidim::Donations
  describe PayOrder do
    subject { described_class.new(form, provider) }

    let(:organization) { create :organization }
    let(:user) { create :user, organization: organization }
    let(:form) do
      double(
        valid?: valid,
        order: order,
        current_user: user,
        attributes: {}
      )
    end
    let(:provider) do
      double(
        amount_in_cents: 1200,
        transaction_id: "some-id",
        method: :paypal_express
      )
    end
    let(:order) do
      {
        title: "some title",
        description: "some description"
      }
    end
    let(:response) do
      double(
        success?: success,
        params: {}
      )
    end
    let(:valid) { true }
    let(:success) { true }

    before do
      allow(provider).to receive(:purchase).and_return(response)
    end

    it "is valid" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "creates a donation" do
      expect { subject.call }.to change(Donation, :count).by(1)
    end

    context "when the form is not valid" do
      let(:valid) { false }

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    context "and there's a payment error" do
      before do
        allow(provider).to receive(:purchase).and_raise(Decidim::Donations::PaymentError)
      end

      it "is not valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
