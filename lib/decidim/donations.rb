# frozen_string_literal: true

require_relative "donations/version"
require_relative "donations/verification"

module Decidim
  module Donations
    include ActiveSupport::Configurable

    config_accessor :minimum_amount do
      1
    end
  end
end
