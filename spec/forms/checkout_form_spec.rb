# frozen_string_literal: true

require "spec_helper"

module Decidim::Donations
  describe CheckoutForm do
    subject do
      described_class.from_params(
        attributes
      ).with_context(context)
    end

    let(:organization) { create :organization }
    let(:context) do
      {
        current_organization: organization,
        minimum_amount: nil
      }
    end
    let(:amount) { 15 }
    let(:token) { nil }
    let(:attributes) do
      {
        amount: amount,
        token: token
      }
    end
    let(:minimum_amount) { 5 }
    let(:default_amount) { 7 }

    before do
      Decidim::Donations.config.minimum_amount = minimum_amount
      Decidim::Donations.config.default_amount = default_amount
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

      context "when minimum is specified through context" do
        let(:context) do
          {
            current_organization: organization,
            minimum_amount: 4
          }
        end

        it { is_expected.to be_valid }
      end
    end
  end
end
