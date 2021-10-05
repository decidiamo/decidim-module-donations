# frozen_string_literal: true

module Decidim
  module Donations
    # This is an engine that performs user authorization.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Donations

      routes do
        authenticate(:user) do
          resource :user_donations do
            get :checkout, on: :collection
          end
        end
      end

      initializer "decidim_donations.assets" do |app|
        app.config.assets.precompile += %w(decidim_donations_manifest.css decidim_donations_manifest.js)
      end

      initializer "decidim_donations.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Donations::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Donations::Engine.root}/app/views") # for partials
      end

      initializer "decidim_donations.content_blocks" do
        Decidim.content_blocks.register(:homepage, :donations) do |content_block|
          content_block.cell = "decidim/donations/content_blocks/donations"
          content_block.public_name_key = "decidim.donations.content_blocks.donations.name"
          content_block.settings_form_cell = "decidim/donations/content_blocks/donations_settings_form"

          content_block.settings do |settings|
            settings.attribute :amount_goal, type: :integer, default: 0
            settings.attribute :total_goal, type: :integer, default: 0
            settings.attribute :start_date, type: :text, default: nil # SettingsManifest does not have date type
          end
        end
        Decidim.content_blocks.register(:participatory_process_group_homepage, :donations) do |content_block|
          content_block.cell = "decidim/donations/content_blocks/donations"
          content_block.public_name_key = "decidim.donations.content_blocks.donations.name"
          content_block.settings_form_cell = "decidim/donations/content_blocks/donations_settings_form"

          content_block.settings do |settings|
            # settings.attribute :max_results, type: :integer, default: 4
          end
        end
      end

      initializer "decidim_donations.user_menu" do
        Decidim.menu :user_menu do |menu|
          menu.item t("menu.title", scope: "decidim.donations.user_profile"),
                    decidim_user_donations.user_donations_path,
                    position: 1.5
        end
      end
    end
  end
end
