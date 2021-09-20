# frozen_string_literal: true

module Decidim
  module Donations
    class AmountFormCell < Decidim::ViewModel
      include PaymentGateway

      def form
        model
      end

      def minimum_amount
        form.context&.minimum_amount || Donations.config.minimum_amount
      end

      def default_amount
        Donations.config.default_amount
      end

      def process_path
        form.context.process_path
      end

      def terms_and_conditions
        @terms_and_conditions ||= I18n.t(Donations.terms_and_conditions, default: Donations.terms_and_conditions)
      end

      def formmatted_amount(amount)
        "<span class=\"amount\">#{I18n.t("formated_amount", amount: amount, scope: "decidim.donations")}</span>"
      end
    end
  end
end
