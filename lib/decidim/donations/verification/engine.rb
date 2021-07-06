# frozen_string_literal: true

module Decidim
  module Donations
    module Verification
      # This is an engine that performs user authorization.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Donations::Verification

        routes do
          resource :authorizations, only: [:new, :create, :edit], as: :authorization do
            get :renew, on: :collection
            get :checkout, on: :collection
          end

          root to: "authorizations#new"
        end

        initializer "decidim_donations.assets" do |app|
          app.config.assets.precompile += %w(decidim_donations_manifest.css
                                             decidim/donations/verification.scss)
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
