# frozen_string_literal: true

require "spec_helper"
require "decidim/dev/test/form_to_param_shared_examples"

module Decidim::Donations
  describe CheckoutForm do
    subject do
      described_class.from_params(
        attributes
      ).with_context(current_organization: organization)
    end

    let(:organization) { create :organization }

    let(:amount) { 15 }
    let(:token) { nil }
    let(:attributes) do
      {
        amount: amount,
        token: token
      }
    end

    it { is_expected.to be_valid }

    it "returns a hash order" do
      expect(subject.order).to be_a(Hash)
      expect(subject.order[:amount]).to eq(amount)
    end

    shared_examples "amount invalid" do
      it {
        expect(subject).to be_invalid
      }

      context "and token present" do
        let(:token) { "some-token" }

        it { is_expected.to be_valid }
      end
    end

    context "when no amount" do
      let(:amount) { nil }

      it_behaves_like "amount invalid"
    end

    context "when amount is zero" do
      let(:amount) { 0 }

      it_behaves_like "amount invalid"
    end

    context "when amount below minimum" do
      let(:amount) { 4 }

      it_behaves_like "amount invalid"
    end
  end
end
