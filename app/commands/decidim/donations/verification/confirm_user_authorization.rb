# frozen_string_literal: true

module Decidim
  module Donations
    module Verification
      class ConfirmUserAuthorization < Decidim::Verifications::ConfirmUserAuthorization
        def call
          return broadcast(:invalid) unless form.valid?

          amount = form.amount

          # TODO: connecto payment gateweay

          authorization.update(metadata: {
                                 "amount" => amount
                               })

          authorization.grant!

          broadcast(:ok)
        end
      end
    end
  end
end
