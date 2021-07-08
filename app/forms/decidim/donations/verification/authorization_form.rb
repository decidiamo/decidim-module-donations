# frozen_string_literal: true

module Decidim
  module Donations
    module Verification
      class AuthorizationForm < AuthorizationHandler
        attribute :handler_handle, String, default: "donations"
        attribute :transaction_id, String

        validates :handler_handle,
                  presence: true,
                  inclusion: {
                    in: proc { |form|
                      form.current_organization.available_authorizations
                    }
                  }
        validates :transaction_id, presence: true

        def unique_id
          Digest::MD5.hexdigest(
            "#{transaction_id}-#{Rails.application.secrets.secret_key_base}"
          )
        end
      end
    end
  end
end
