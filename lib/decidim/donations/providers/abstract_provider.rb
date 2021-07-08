# frozen_string_literal: true

require "active_merchant"

module Decidim
  module Donations
    module Providers
      class AbstractProvider
        class << self
          def manifest_name
            name.demodulize.underscore
          end

          def provider_name
            I18n.t("providers.#{manifest_name}", scope: "decidim.donations")
          end
        end

        def initialize(login:, password:)
          @gateway = ActiveMerchant::Billing::TrustCommerceGateway(login: login, password: password)
        end

        attr_reader :gateway
        attr_accessor :amount, :transaction_id, :order

        def name
          self.class.provider_name
        end

        def method
          self.class.manifest_name
        end

        def amount_in_cents
          (amount * 100).to_i
        end

        def multistep?
          false
        end

        # depending on the provider the setup_purchase might have different parameters
        # only called on multistep providers
        def setup_purchase(order:, params: {})
          raise NotImplementedError
        end

        # assign @amount and @transaction_id and @order hash here
        def purchase(order:, params: {})
          raise NotImplementedError
        end

        # unique identifier for the last transaction made
        def transaction_hash
          raise PaymentError unless transaction_id

          "#{method}-#{transaction_id}"
        end
      end
    end
  end
end
