# frozen_string_literal: true

require "active_support/concern"
require "activemerchant"

module Decidim
  module Donations
    # Common logic to renew authorizations
    module PaymentGateway
      extend ActiveSupport::Concern
      included do
        def provider
          return @provider if @provider

          ActiveMerchant::Billing::Base.mode = Donations.mode

          klass = "Decidim::Donations::Providers::#{Donations.provider.to_s.camelize}".constantize
          @provider = klass.new Donations.credentials
        end
      end
    end
  end
end
