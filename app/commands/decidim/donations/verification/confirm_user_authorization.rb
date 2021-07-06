# frozen_string_literal: true

module Decidim
  module Donations
    module Verification
      class ConfirmUserAuthorization < Decidim::Verifications::ConfirmUserAuthorization
        def call
          return broadcast(:invalid) unless form.valid?

          authorization.update(metadata: {
                                 "amount" => form.context.provider.amount,
                                 "transaction_id" => form.context.provider.transaction_id
                               })

          authorization.grant!

          broadcast(:ok)
        end
      end
    end
  end
end
