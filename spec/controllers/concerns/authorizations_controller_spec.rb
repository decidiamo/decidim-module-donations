# frozen_string_literal: true

require "spec_helper"

module Decidim::Donations::Verification
  describe AuthorizationsController, type: :controller do
    routes { Decidim::Donations::Verification::Engine.routes }

    let(:organization) do
      create(
        :organization,
        available_authorizations: ["donations"]
      )
    end
    let(:current_user) { create(:user, :confirmed, organization: organization) }
    let(:credentials) do
      {
        login: "login",
        password: "password",
        signature: "signature"
      }
    end

    before do
      request.env["decidim.current_organization"] = organization
      Decidim::Donations.provider = :paypal_express
      Decidim::Donations.credentials = credentials
      sign_in current_user, scope: :user
    end

    context "when requesting a new authrorization" do
      it "renders new template" do
        get :new

        expect(subject.helpers.provider).to be_a(Decidim::Donations::Providers::PaypalExpress)
      end
    end
  end
end
