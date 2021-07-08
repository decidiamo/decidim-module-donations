# frozen_string_literal: true

module Decidim
  module Donations
    module Verification
      module Admin
        class DonationsController < Decidim::Admin::ApplicationController
          include ActionView::Helpers::NumberHelper

          helper_method :donations, :amount_to_currency

          def index
            enforce_permission_to :index, :authorization
          end

          def show
            enforce_permission_to :read, :authorization
          end

          def new
            enforce_permission_to :create, :authorization
          end

          private

          def donations
            Donation
              .joins(:user)
              .where(decidim_users: { decidim_organization_id: current_organization.id }).page(params[:page]).per(50)
          end

          def amount_to_currency(amount)
            number_to_currency amount, unit: Decidim.currency_unit, precision: 2
          end
        end
      end
    end
  end
end
