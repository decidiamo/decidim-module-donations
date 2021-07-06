# frozen_string_literal: true

module Decidim
  module Donations
    module Verification
      class AuthorizationsController < Decidim::ApplicationController
        include Decidim::Verifications::Renewable
        include FormFactory
        include PaymentGateway

        helper_method :authorization

        before_action do
          enforce_permission_to :create, :authorization, authorization: authorization
        end

        def new
          @form = checkout_form
        end

        # preparation step and redirect to gateway
        def create
          @form = checkout_form
          if provider.multistep?
            response = provider.setup_purchase(order: @form.order, params: @form.attributes)
            if response.success?
              Rails.logger.info "Payment token redirect. #{response.token}"
              return redirect_to provider.gateway.redirect_url_for(response.token)
            else
              Rails.logger.error "Payment token redirect error. #{response.message}"
            end

            flash[:alert] = t("checkout.error", scope: "decidim.donations", message: response.message)
            return redirect_to decidim_donations.new_authorization_path
          end
          # TODO: check if this works for providers non multistep provider (ie non paypal)
          checkout
        end

        # payment
        def checkout
          @form = checkout_form
          PayOrder.call(@form, provider) do
            on(:ok) do |response|
              flash[:notice] = t("checkout.success", scope: "decidim.donations")

              Rails.logger.info "Payment successful! #{response.params}"
              create_verification(provider)
            end

            on(:invalid) do |message|
              flash[:alert] = t("checkout.error", scope: "decidim.donations", message: message)
              redirect_to decidim_donations.new_authorization_path
            end
          end
        end

        def edit; end

        private

        def checkout_form
          form(CheckoutForm).from_params(params,
                                         ip: request.remote_ip,
                                         return_url: decidim_donations.checkout_authorization_url,
                                         cancel_return_url: decidim_donations.checkout_authorization_url,
                                         title: I18n.t("checkout.title", name: current_user.name, scope: "decidim.donations"),
                                         description: I18n.t("checkout.description", organization: current_organization.name, scope: "decidim.donations"))
        end

        def create_verification(provider)
          @form = form(AuthorizationForm).instance({ provider: provider })
          Decidim::Donations::Verification::ConfirmUserAuthorization.call(authorization, @form, session) do
            on(:ok) do
              flash[:notice] = t("authorizations.create.success", scope: "decidim.donations.verification")
              redirect_to decidim_verifications.authorizations_path
            end

            on(:invalid) do
              flash[:alert] = t("authorizations.create.error", scope: "decidim.donations.verification")
              redirect_to decidim_donations.new_authorization_path
            end
          end
        end

        def authorization
          @authorization ||= Decidim::Authorization.find_or_initialize_by(
            user: current_user,
            name: "donations"
          )
        end
      end
    end
  end
end
