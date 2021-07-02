# frozen_string_literal: true

module Decidim
  module Donations
    module Verification
      # A form object for users to enter their access code to get verified.
      class AuthorizationForm < AuthorizationHandler
        attribute :amount, Integer, default: Donations.default_amount
        attribute :handler_handle, String

        validates :handler_handle,
                  presence: true,
                  inclusion: {
                    in: proc { |form|
                      form.current_organization.available_authorizations
                    }
                  }
        validates :amount, numericality: { greater_than_or_equal_to: Donations.minimum_amount }

        def handler_name
          handler_handle
        end
      end
    end
  end
end
