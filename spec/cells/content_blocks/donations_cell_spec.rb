# frozen_string_literal: true

require "spec_helper"

module Decidim::Donations
  describe ContentBlocks::DonationsCell, type: :cell do
    subject { cell(content_block.cell, content_block).call }

    let(:user) { create(:user) }
    let(:organization) { user.organization }
    let(:content_block) { create :content_block, organization: organization, manifest_name: :donations, scope_name: :homepage, settings: settings }
    let(:settings) do
      {}
    end

    controller Decidim::PagesController

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    it "shows summary" do
      expect(subject).to have_selector("#donations-summary")
      expect(subject).to have_content(".animate-number")
      expect(subject).to have_content("Make a new donation")
    end

    it "shows empty amounts" do
      expect(subject).to have_content("€0")
      expect(subject).to have_content("0 donations")
    end

    context "when there is one donation" do
      let!(:donation) { create :donation, user: user, amount: 8700 }

      it "shows the amounts" do
        expect(subject).to have_content("€87")
        expect(subject).to have_content("1 donations")
      end
    end

    context "when there are several donations" do
      let!(:donation1) { create :donation, user: user, amount: 8700 }
      let!(:donation2) { create :donation, user: user, amount: 1700 }
      let!(:donation3) { create :donation, user: user, amount: 5000 }

      shared_examples "exact amount" do
        it "shows the amounts" do
          expect(subject).to have_content("€154")
          expect(subject).to have_content("3 donations")
        end
      end

      it_behaves_like "exact amount"

      context "and there are donations from other organizations" do
        let!(:donation4) { create :donation, amount: 5000 }
      
        it_behaves_like "exact amount"
      end
    end
  end
end
