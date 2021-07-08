# frozen_string_literal: true

require "spec_helper"

module Decidim::Donations::Verification
  describe ConfirmUserAuthorization do
    subject { described_class.new(authorization, form, session) }

    let(:session) { {} }

    let(:authorization) do
      create(
        :authorization,
        :pending,
        unique_id: "unique-id",
        name: "donations"
      )
    end

    let(:form) do
      double(
        valid?: valid,
        context: double(provider: provider),
        transaction_id: provider.transaction_id,
        unique_id: "unique-id"
      )
    end
    let(:valid) { true }
    let(:provider) do
      double(
        amount: 12,
        amount_in_cents: 1200,
        transaction_id: "some-id",
        method: :paypal_express
      )
    end
    let!(:donation) { create :donation, reference: provider.transaction_id }

    it "is valid" do
      expect { subject.call }.to broadcast(:ok)
    end

    it "saves the unique_id" do
      expect(donation.authorization_unique_id).to eq(nil)
      expect(authorization.unique_id).not_to eq(nil)

      subject.call

      expect(donation.reload.authorization_unique_id).to eq(authorization.unique_id)
    end
  end
end
