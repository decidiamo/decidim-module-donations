# frozen_string_literal: true

module Decidim
  module Donations
    module Verification
      module Admin
        class DonationsController < Decidim::Admin::ApplicationController
          include ActionView::Helpers::NumberHelper
          include Paginable

          helper Decidim::Donations::DonationsHelper
          helper_method :donations

          def index
            enforce_permission_to :index, :authorization
          end

          def create
            enforce_permission_to :create, :authorization
            CreateDonationAuthorization.call(donation) do
              on(:ok) do |donation|
                flash[:notice] = t("verification.success", scope: "decidim.donations.verification.admin.donations", user: donation.user.name, donation: donation.id)
              end

              on(:invalid) do |message|
                flash[:alert] = t("verification.error", scope: "decidim.donations.verification.admin.donations", message: message)
              end
            end
            redirect_back(fallback_location: decidim_admin_donations.donations_path)
          end

          private

          def donations
            paginate(Donation
              .joins(:user)
              .where(decidim_users: { decidim_organization_id: current_organization.id }))
          end

          def donation
            @donation ||= Donation.find(params[:donation_id])
          end

          def per_page
            50
          end
        end
      end
    end
  end
end
