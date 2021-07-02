# frozen_string_literal: true

require_relative "donations/version"
require_relative "donations/verification"

module Decidim
  module Donations
    include ActiveSupport::Configurable

    config_accessor :minimum_amount do
      5
    end

    config_accessor :default_amount do
      10
    end
  end
end
