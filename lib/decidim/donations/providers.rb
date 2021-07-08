# frozen_string_literal: true

module Decidim
  module Donations
    module Providers
      autoload :AbstractProvider, "decidim/donations/providers/abstract_provider"
      autoload :PaypalExpress, "decidim/donations/providers/paypal_express"
    end
  end
end
