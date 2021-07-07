# frozen_string_literal: true

require "spec_helper"

module Decidim::Donations::Verification
  describe AuthorizationForm do
    subject { form }

    let(:organization) do
      create(:organization, available_authorizations: ["donations"])
    end
    let(:user) { create :user, organization: organization }
    let(:params) do
      {
        transaction_id: transaction_id,
        user: user
      }
    end

    let(:form) do
      described_class.from_params(params).with_context(
        current_organization: organization
      )
    end

    let(:transaction_id) { "some-id" }

    it { is_expected.to be_valid }

    it "returns a unique_id" do
      expect(subject.unique_id).to be_a(String)
    end

    context "when no transaction" do
      let(:transaction_id) { nil }

      it { is_expected.to be_invalid }
    end
  end
end
