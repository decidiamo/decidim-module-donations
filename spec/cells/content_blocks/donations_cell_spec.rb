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
      let!(:donation1) { create :donation, user: user, amount: 8700, created_at: 1.day.ago }
      let!(:donation2) { create :donation, user: user, amount: 1700, created_at: 2.days.ago }
      let!(:donation3) { create :donation, user: user, amount: 5000, created_at: 3.days.ago }

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

      context "when a date is defined" do
        let(:settings) do
          {
            start_date: I18n.l(2.days.ago, format: :decidim_short)
          }
        end

        it "shows the amounts" do
          expect(subject).to have_content("€104")
          expect(subject).to have_content("2 donations")
        end
      end

      context "when an amount goal is defined" do
        let(:settings) do
          {
            amount_goal: 213
          }
        end

        it_behaves_like "exact amount"

        it "shows the percent" do
          expect(subject).to have_content("amount goal: €213")
          expect(subject).to have_content("72%")
          expect(subject).not_to have_content("60%")
        end

        context "and is surpassed" do
          let(:settings) do
            {
              amount_goal: 100
            }
          end

          it "shows 100%" do
            expect(subject).to have_content("100%")
          end
        end
      end

      context "when a total goal is defined" do
        let(:settings) do
          {
            total_goal: 5
          }
        end

        it_behaves_like "exact amount"

        it "shows the percent" do
          expect(subject).to have_content("donations goal: 5")
          expect(subject).to have_content("60%")
          expect(subject).not_to have_content("72%")
        end

        context "and is surpassed" do
          let(:settings) do
            {
              total_goal: 2
            }
          end

          it "shows 100%" do
            expect(subject).to have_content("100%")
          end
        end
      end
    end
  end
end
