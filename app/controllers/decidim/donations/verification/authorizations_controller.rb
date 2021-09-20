# frozen_string_literal: true

module Decidim
  module Donations
    module Verification
      class AuthorizationsController < Decidim::ApplicationController
        include Decidim::Verifications::Renewable
        include FormFactory
        include PaymentGateway

        helper_method :authorization

        def new
          enforce_permission_to :create, :authorization, authorization: authorization

          @form = checkout_form
        end

        # preparation step and redirect to gateway
        def create
          enforce_permission_to :create, :authorization, authorization: authorization

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
            return redirect_to decidim_donations.new_authorization_path
          end
          # TODO: check if this works for providers non-multistep (ie non paypal)
          checkout
        end

        # payment
        def checkout
          enforce_permission_to :create, :authorization, authorization: authorization

          @form = checkout_form
          PayOrder.call(@form, provider) do
            on(:ok) do |response|
              flash[:notice] = t("checkout.success", scope: "decidim.donations")

              Rails.logger.info "Payment successful! #{response.params}"
              create_verification
            end

            on(:invalid) do |message|
              flash[:alert] = t("checkout.error", scope: "decidim.donations", message: message)
              redirect_to decidim_donations.new_authorization_path
            end
          end
        end

        private

        def create_verification
          Decidim::Donations::Verification::ConfirmUserAuthorization.call(authorization, authorization_form, session) do
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

        def checkout_form
          form(CheckoutForm).from_params(params,
                                         ip: request.remote_ip,
                                         return_url: decidim_donations.checkout_authorization_url,
                                         cancel_return_url: decidim_donations.checkout_authorization_url,
                                         process_path: authorization_path,
                                         title: I18n.t("checkout.title", name: current_user.name, scope: "decidim.donations"),
                                         description: I18n.t("checkout.description", organization: current_organization.name, scope: "decidim.donations"),
                                         minimum_amount: Donations.verification_amount)
        end

        def authorization_form
          form(AuthorizationForm).from_params(
            { user: current_user, transaction_id: provider.transaction_hash },
            { provider: provider }
          )
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
