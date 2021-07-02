# frozen_string_literal: true

Decidim::Verifications.register_workflow(:donations) do |workflow|
  workflow.engine = Decidim::Donations::Verification::Engine
  workflow.admin_engine = Decidim::Donations::Verification::AdminEngine
end
