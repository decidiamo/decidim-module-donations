# frozen_string_literal: true

module Decidim
  module Donations
    module Verification
      class ConfirmUserAuthorization < Decidim::Verifications::ConfirmUserAuthorization
        def call
          return broadcast(:invalid) unless form.valid?

          authorization.update(metadata: {
                                 "amount" => form.context.provider.amount,
                                 "transaction_id" => form.transaction_id
                               },
                               unique_id: form.unique_id)
          authorization.grant!

          # update donation
          Donation.update(authorization_unique_id: authorization.unique_id)

          broadcast(:ok)
        end
      end
    end
  end
end
