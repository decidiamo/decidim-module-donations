# frozen_string_literal: true

module Decidim
  module Donations
    class UserDonationsController < Decidim::ApplicationController
      include Decidim::UserProfile
      include ActionView::Helpers::NumberHelper
      include PaymentGateway

      helper Decidim::Donations::DonationsHelper
      helper_method :donations

      def show
        enforce_permission_to :read, :user, current_user: current_user
      end

      def new
        enforce_permission_to :read, :user, current_user: current_user
        @form = checkout_form
      end

      def create
        enforce_permission_to :read, :user, current_user: current_user

        @form = checkout_form

        if @form.invalid?
          flash[:alert] = t("checkout.error", scope: "decidim.donations", message: t("checkout.amount_errors", scope: "decidim.donations"))
          return render :new
        end

        if provider.multistep?
          response = provider.setup_purchase(order: @form.order, params: @form.attributes)
          if response.success?
            Rails.logger.info "Payment token redirect. #{response.token}"
            return redirect_to provider.gateway.redirect_url_for(response.token)
          else
            Rails.logger.error "Payment token redirect error. #{response.message}"
          end

          flash[:alert] = t("checkout.error", scope: "decidim.donations", message: response.message)
          return redirect_to decidim_user_donations.user_donations_path
        end
        checkout
      end

      # payment
      def checkout
        enforce_permission_to :read, :user, current_user: current_user

        @form = checkout_form
        PayOrder.call(@form, provider) do
          on(:ok) do |response|
            flash[:notice] = t("checkout.success", scope: "decidim.donations")

            Rails.logger.info "Payment successful! #{response.params}"
            redirect_to decidim_user_donations.user_donations_path
          end

          on(:invalid) do |message|
            flash[:alert] = t("checkout.error", scope: "decidim.donations", message: message)
            redirect_to decidim_user_donations.user_donations_path
          end
        end
      end

      private

      def donations
        Donation.where(user: current_user).page(params[:page]).per(50)
      end

      def checkout_form
        form(CheckoutForm).from_params(params,
                                       ip: request.remote_ip,
                                       return_url: decidim_user_donations.checkout_user_donations_url,
                                       cancel_return_url: decidim_user_donations.checkout_user_donations_url,
                                       process_path: decidim_user_donations.user_donations_path,
                                       title: I18n.t("checkout.title", name: current_user.name, scope: "decidim.donations"),
                                       description: I18n.t("checkout.description", organization: current_organization.name, scope: "decidim.donations"))
      end
    end
  end
end
