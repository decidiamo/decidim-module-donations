# frozen_string_literal: true

require "spec_helper"

module Decidim::Donations::Verification::Admin
  describe CreateDonationAuthorization do
    subject { described_class.new(donation) }

    let!(:donation) { create :donation, success: success, authorization: authorization }
    let(:success) { true }
    let(:authorization) { nil }

    shared_examples "valid" do
      it "is valid" do
        expect { subject.call }.to broadcast(:ok)
      end

      it "saves the unique_id" do
        expect(donation.authorization_unique_id).to eq(nil)
        expect(donation.authorization).to eq(nil)

        subject.call

        expect(donation.authorization.unique_id).not_to eq(nil)
        expect(donation.reload.authorization_unique_id).to eq(donation.authorization.unique_id)
      end
    end

    shared_examples "invalid" do
      it "is valid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end

    it_behaves_like "valid"

    context "when donation unsuccessful" do
      let(:success) { false }

      it_behaves_like "invalid"
    end

    context "when authorization already exists" do
      let(:authorization) { create(:authorization, :pending, name: "donations") }

      it_behaves_like "invalid"
    end
  end
end
