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
        transaction_id: "some-id"
      )
    end

    it "is valid" do
      expect { subject.call }.to broadcast(:ok)
    end
  end
end
