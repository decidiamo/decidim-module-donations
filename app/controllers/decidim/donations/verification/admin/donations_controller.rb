# frozen_string_literal: true

module Decidim
  module Donations
    module Verification
      module Admin
        class DonationsController < Decidim::Admin::ApplicationController
          include ActionView::Helpers::NumberHelper

          helper Decidim::Donations::DonationsHelper
          helper_method :donations

          def index
            enforce_permission_to :index, :authorization
          end

          private

          def donations
            Donation
              .joins(:user)
              .where(decidim_users: { decidim_organization_id: current_organization.id }).page(params[:page]).per(50)
          end
        end
      end
    end
  end
end
