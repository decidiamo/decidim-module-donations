# frozen_string_literal: true

module Decidim
  module Donations
    module Verification
      module Admin
        class CreateDonationAuthorization < Rectify::Command
          def initialize(donation)
            @donation = donation
          end

          def call
            return broadcast(:invalid, error) unless successful_donation?
            return broadcast(:invalid, error) unless already_authorized_donation?

            create_authorization!
            donation.update!(authorization_unique_id: authorization.unique_id)

            broadcast(:ok, donation)
          end

          private

          attr_reader :donation, :error

          def authorization
            @authorization ||= Decidim::Authorization.find_or_initialize_by(
              user: donation.user,
              name: "donations"
            )
          end

          def form
            @form ||= AuthorizationForm.from_params(transaction_id: donation.reference)
          end

          def create_authorization!
            authorization.update(metadata: {
                                   "amount" => donation.decimal_amount,
                                   "transaction_id" => donation.reference
                                 },
                                 unique_id: form.unique_id)
            authorization.grant!
          end

          def successful_donation?
            return true if donation.success?

            @error = I18n.t("verification.payment_invalid", scope: "decidim.donations.verification.admin.donations")
            false
          end

          def already_authorized_donation?
            return true if donation.authorization_status == :none

            @error = I18n.t("verification.already_authorized", scope: "decidim.donations.verification.admin.donations")
            false
          end
        end
      end
    end
  end
end
