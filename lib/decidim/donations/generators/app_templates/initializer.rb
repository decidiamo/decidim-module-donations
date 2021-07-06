# frozen_string_literal: true

Decidim::Verifications.register_workflow(:donations) do |workflow|
  workflow.engine = Decidim::Donations::Verification::Engine
  workflow.admin_engine = Decidim::Donations::Verification::AdminEngine
end

Decidim::Donations.credentials do
  config.credentials = {
    login: Rails.application.secrets.donations[:login],
    password: Rails.application.secrets.donations[:password],
    signature: Rails.application.secrets.donations[:signature]
  }
end
