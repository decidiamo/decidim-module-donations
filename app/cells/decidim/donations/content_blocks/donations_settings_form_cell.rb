# frozen_string_literal: true

module Decidim
  module Donations
    module ContentBlocks
      class DonationsSettingsFormCell < Decidim::ViewModel
        alias form model

        def i18n_scope
          "decidim.donations.content_blocks.donations_settings_form"
        end
      end
    end
  end
end
