# frozen_string_literal: true

require_relative "donations/version"
require_relative "donations/verification"
require_relative "donations/providers"

module Decidim
  module Donations
    class PaymentError < StandardError; end

    include ActiveSupport::Configurable

    config_accessor :minimum_amount do
      5
    end

    config_accessor :default_amount do
      10
    end

    # The text that appears when donating
    # leave it empty if not necessary
    # you can also put a (full) I18n key
    config_accessor :terms_and_conditions do
      "decidim.donations.terms_and_conditions"
    end

    # :test / :production
    config_accessor :mode do
      Rails.env.production? ? :production : :test
    end

    # Payment currency: ISO 4217
    # in addition, configure Decidim.current_unit for the symbol used in the UI
    config_accessor :currency do
      "EUR"
    end

    config_accessor :provider do
      :paypal_express
    end

    config_accessor :credentials do
      {
        # login: Rails.application.secrets.donations[:login],
        # password: Rails.application.secrets.donations[:password],
        # signature: Rails.application.secrets.donations[:signature]
      }
    end

    def self.find_provider_class(method)
      "Decidim::Donations::Providers::#{method.camelize}".safe_constantize
    end
  end
end
