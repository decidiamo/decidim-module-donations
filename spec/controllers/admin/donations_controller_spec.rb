# frozen_string_literal: true

require "spec_helper"

module Decidim::Donations::Verification
  describe Admin::DonationsController, type: :controller do
    routes { Decidim::Donations::Verification::AdminEngine.routes }

    let(:organization) do
      create(
        :organization,
        available_authorizations: ["donations"]
      )
    end
    let(:user) { create(:user, :admin, organization: organization) }
    let(:another_user) { create(:user, :confirmed) }
    let!(:donation1) { create(:donation, amount: 12_300, user: user) }
    let!(:donation2) { create(:donation, amount: 45_600, user: user) }
    let!(:donation3) { create(:donation, amount: 45_600, success: false, user: user) }
    let!(:another_donation) { create(:donation, amount: 78_900, user: another_user) }

    before do
      request.env["decidim.current_organization"] = organization
      sign_in user, scope: :user
    end

    it "lists current donations" do
      get :index

      expect(response).to render_template(:index)
    end

    it "list own donations" do
      get :index

      expect(controller.helpers.donations.all).to include(donation1)
      expect(controller.helpers.donations.all).to include(donation2)
      expect(controller.helpers.donations.all).to include(donation3)
    end

    it "do not list other organization donations" do
      get :index

      expect(controller.helpers.donations.all).not_to include(another_donation)
    end

    it "gets the total amount of donations" do
      get :index

      expect(controller.helpers.total_donations).to eq(3)
    end

    it "gets the total amount of successful donations" do
      get :index

      expect(controller.helpers.total_donations_successful).to eq(2)
    end

    it "gets the total amount of successful donations amount" do
      get :index

      expect(controller.helpers.total_donations_amount).to eq(579.0)
    end
  end
end
