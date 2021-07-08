# frozen_string_literal: true

require "spec_helper"

module Decidim::Donations::Verification
  describe UserDonationsController, type: :controller do
    routes { Decidim::Donations::Verification::Engine.routes }

    let(:organization) do
      create(
        :organization,
        available_authorizations: ["donations"]
      )
    end
    let(:user) { create(:user, :confirmed, organization: organization) }
    let!(:donation) { create(:donation, amount: 12_300, user: user) }
    let!(:another_donation) { create(:donation, amount: 45_600) }

    before do
      request.env["decidim.current_organization"] = organization
      sign_in user, scope: :user
    end

    it "lists current donations" do
      get :show

      expect(response).to render_template(:show)
    end

    it "list own donations" do
      get :show

      expect(controller.helpers.donations.all).to include(donation)
    end

    it "do not list others donations" do
      get :show

      expect(controller.helpers.donations.all).not_to include(another_donation)
    end
  end
end
