# frozen_string_literal: true

Decidim::Verifications.register_workflow(:donations) do |workflow|
  workflow.engine = Decidim::Donations::Verification::Engine
  workflow.admin_engine = Decidim::Donations::Verification::AdminEngine

  # Next is optional (defaults to Non-renewable)
  # workflow.expires_in = 1.year
  # workflow.renewable = true
  # workflow.time_between_renewals = 1.month
end

Decidim::Donations.configure do |config|
  config.minimum_amount = 1
  config.verification_amount = 5 # if this config is omitted, defaults to minimum_amount
  config.default_amount = 10

  config.provider = :paypal_express # currently only this one is supported
  config.credentials = {
    login: Rails.application.secrets.donations&.login,
    password: Rails.application.secrets.donations&.password,
    signature: Rails.application.secrets.donations&.signature
  }
end
