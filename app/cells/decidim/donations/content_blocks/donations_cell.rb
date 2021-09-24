# frozen_string_literal: true

module Decidim
  module Donations
    module ContentBlocks
      class DonationsCell < Decidim::ViewModel
        include ActionView::Helpers::NumberHelper
        include Decidim::Donations::DonationsHelper

        def amount
          amount_to_currency(total_donations_amount)
        end

        def amount_formatted
          "<strong class='animate-number'>#{amount}</strong>"
        end

        def amount_goal
          model.settings.amount_goal
        end

        def total_formatted
          "<strong class='animate-number'>#{total_donations_successful}</strong>"
        end

        def collected_text
          date = model.settings.start_date
          if date.blank?
            t("collected_so_far", amount: amount_formatted, total: total_formatted, scope: i18n_scope)
          else
            t("collected_since", date: date, amount: amount_formatted, total: total_formatted, scope: i18n_scope)
          end
        end

        def total_goal
          model.settings.total_goal
        end

        def percent(num, max)
          return nil unless max.to_i.positive?

          [100, (100 * (num / max.to_f)).round].min
        end

        def i18n_scope
          "decidim.donations.content_blocks.donations"
        end

        def circle(percent, color: :primary)
          return if percent.nil?

          text = "#{percent}%"
          "<div class='center c100 p#{percent} #{color}'>
            <span>#{text}</span>
            <div class='slice'>
              <div class='bar'></div>
              <div class='fill'></div>
            </div>
          </div>"
        end

        def decidim_donations
          Decidim::Donations::Verification::Engine.routes.url_helpers
        end

        private

        def donations
          donations = Donation
                      .joins(:user)
                      .where(decidim_users: { decidim_organization_id: current_organization.id })
          date = begin
            Date.parse(model.settings.start_date)
          rescue StandardError
            nil
          end
          if date
            donations.where("decidim_donations_donations.created_at >= ?", date)
          else
            donations
          end
        end
      end
    end
  end
end
