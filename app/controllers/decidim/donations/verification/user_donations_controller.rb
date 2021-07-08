# frozen_string_literal: true

module Decidim
  module Donations
    module Verification
      class UserDonationsController < Decidim::ApplicationController
        include Decidim::UserProfile
        include ActionView::Helpers::NumberHelper

        helper Decidim::Donations::DonationsHelper
        helper_method :donations

        def show
          enforce_permission_to :read, :user, current_user: current_user
        end

        private

        def donations
          Donation.where(user: current_user).page(params[:page]).per(50)
        end
      end
    end
  end
end
