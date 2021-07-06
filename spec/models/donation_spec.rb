# frozen_string_literal: true

require "spec_helper"

module Decidim::Donations
  describe Donation do
    subject { donation }

    let(:donation) { build :donation }

    describe "validations" do
      it "is valid" do
        expect(subject).to be_valid
      end
    end
  end
end
