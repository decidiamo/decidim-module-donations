# frozen_string_literal: true

require "spec_helper"

module Decidim::Donations
  describe Donation do
    subject { donation }

    let(:donation) { build :donation, authorization_unique_id: id }
    let(:user) { create :user, :confirmed }
    let(:id) { "a-great-id" }
    let!(:authorization) { create(:authorization, name: "donations", user: user, unique_id: id, granted_at: 2.seconds.ago) }

    describe "validations" do
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
    end
  end
end
