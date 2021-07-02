# frozen_string_literal: true

module Decidim
  module Donations
    module Verification
      module Admin
        class DonationsController < Decidim::Admin::ApplicationController
          def index
            enforce_permission_to :index, :authorization
          end

          def show
            enforce_permission_to :read, :authorization
          end

          def new
            enforce_permission_to :create, :authorization
          end
        end
      end
    end
  end
end
