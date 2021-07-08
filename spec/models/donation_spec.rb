# frozen_string_literal: true

require "spec_helper"

module Decidim::Donations
  describe Donation do
    subject { donation }

    let(:donation) { build :donation, method: :paypal_express, amount: 12_301, authorization_unique_id: id }
    let(:user) { create :user, :confirmed }
    let(:id) { "a-great-id" }
    let!(:authorization) { create(:authorization, name: "donations", user: user, unique_id: id, granted_at: 2.seconds.ago) }

    it "is valid" do
      expect(subject).to be_valid
    end

    it "has an authorization associated" do
      expect(subject.authorization).to eq(authorization)
    end

    context "when no authorization is linked" do
      let(:donation) { build :donation }

      it "is valid" do
        expect(subject).to be_valid
      end

      it "has no authorization associated" do
        expect(subject.authorization).to eq(nil)
      end
    end

    it "returns provider class" do
      expect(subject.provider_class).to eq(Decidim::Donations::Providers::PaypalExpress)
    end

    it "returns computed amount" do
      expect(subject.decimal_amount).to eq(123.01)
    end

    it "returns authorization status valid" do
      expect(subject.authorization_status).to eq(:valid)
    end

    context "and authorization is pending" do
      let!(:authorization) { create(:authorization, :pending, name: "donations", user: user, unique_id: id) }

      it "returns authorization status pending" do
        expect(subject.authorization_status).to eq(:pending)
      end
    end

    context "and authorization is expired" do
      before do
        allow(subject.authorization).to receive(:expired?).and_return(true)
      end

      it "returns authorization status expired" do
        expect(subject.authorization_status).to eq(:expired)
      end
    end

    context "and no authorization" do
      let!(:authorization) { nil }

      it "returns authorization status none" do
        expect(subject.authorization_status).to eq(:none)
      end
    end
  end
end
