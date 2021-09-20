# frozen_string_literal: true

require_relative "donations/version"
require_relative "donations/engine"
require_relative "donations/verification"
require_relative "donations/providers"

module Decidim
  module Donations
    class PaymentError < StandardError; end

    include ActiveSupport::Configurable

    # minimum amount to accept a donation
    config_accessor :minimum_amount do
      1
    end

    # minim amount that allows the user to be verificated
    # defaults to minimum_amount
    config_accessor :verification_amount do
      nil
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

    def self.verification_amount
      Donations.config.verification_amount || Donations.config.minimum_amount
    end

    def self.find_provider_class(method)
      "Decidim::Donations::Providers::#{method.camelize}".safe_constantize
    end
  end
end

# Engines to handle logic unrelated to participatory spaces or components need to be registered independently

Decidim.register_global_engine(
  :decidim_user_donations, # this is the name of the global method to access engine routes,
  # can't use decidim_donations as is the one assigned by the verification engine
  ::Decidim::Donations::Engine,
  at: "/donations"
)
