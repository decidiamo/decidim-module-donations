# frozen_string_literal: true

module Decidim
  module Donations
    module Verification
      class AuthorizationForm < AuthorizationHandler
        attribute :handler_handle, String

        validates :handler_handle,
                  presence: true,
                  inclusion: {
                    in: proc { |form|
                      form.current_organization.available_authorizations
                    }
                  }
      end
    end
  end
end
