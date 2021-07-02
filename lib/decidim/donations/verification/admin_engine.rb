# frozen_string_literal: true

module Decidim
  module Donations
    module Verification
      # This is an engine that implements the administration interface for
      # user authorization by donations.
      class AdminEngine < ::Rails::Engine
        isolate_namespace Decidim::Donations::Verification::Admin
        paths["db/migrate"] = nil

        routes do
          resources :donations, only: [:index, :show, :new, :create, :destroy]

          root to: "donations#index"
        end
      end
    end
  end
end
