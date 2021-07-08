# frozen_string_literal: true

module Decidim
  module Donations
    module Verification
      # This is an engine that performs user authorization.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Donations::Verification

        routes do
          resource :authorizations, only: [:new, :create], as: :authorization do
            get :renew, on: :collection
            get :checkout, on: :collection
          end

          authenticate(:user) do
            resource :user_donations, only: [:show]
          end

          root to: "authorizations#new"
        end

        initializer "decidim_donations.assets" do |app|
          app.config.assets.precompile += %w(decidim_donations_manifest.css
                                             decidim/donations/verification.scss)
        end

        initializer "decidim_donations.user_menu" do
          Decidim.menu :user_menu do |menu|
            menu.item t("menu.title", scope: "decidim.donations.user_profile"),
                      decidim_donations.user_donations_path,
                      position: 1.5,
                      active: :exact
          end
        end

        def load_seed
          # Enable the `:donations` authorization
          org = Decidim::Organization.first
          org.available_authorizations << :donations
          org.save!
        end
      end
    end
  end
end
