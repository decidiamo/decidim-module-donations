# frozen_string_literal: true

module Decidim
  module Donations
    module Verification
      class AuthorizationsController < Decidim::ApplicationController
        include Decidim::Verifications::Renewable

        helper_method :authorization

        before_action :authorization

        def new
          enforce_permission_to :create, :authorization, authorization: authorization

          @form = AuthorizationForm.new(handler_handle: "donations").with_context(current_organization: current_organization)
        end

        def create
          enforce_permission_to :create, :authorization, authorization: authorization

          @form = AuthorizationForm.from_params(
            params.merge(user: current_user)
          ).with_context(current_organization: current_organization)

          Decidim::Donations::Verification::ConfirmUserAuthorization.call(authorization, @form, session) do
            on(:ok) do
              flash[:notice] = t("authorizations.create.success", scope: "decidim.donations.verification")
              redirect_to decidim_verifications.authorizations_path
            end

            on(:invalid) do
              flash.now[:alert] = t("authorizations.create.error", scope: "decidim.donations.verification")
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :create, :authorization, authorization: authorization
        end

        private

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
