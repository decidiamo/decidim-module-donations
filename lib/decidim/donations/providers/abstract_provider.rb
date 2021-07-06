# frozen_string_literal: true

require "active_merchant"

module Decidim
  module Donations
    module Providers
      class AbstractProvider
        def initialize(login:, password:)
          @gateway = ActiveMerchant::Billing::TrustCommerceGateway(login: login, password: password)
        end

        attr_reader :gateway
        attr_accessor :amount, :transaction_id, :order

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
      end
    end
  end
end
