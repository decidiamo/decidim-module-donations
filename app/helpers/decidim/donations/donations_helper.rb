# frozen_string_literal: true

module Decidim
  module Donations
    module DonationsHelper
      def amount_to_currency(amount)
        number_to_currency amount, unit: Decidim.currency_unit, precision: 2
      end

      def tr_classes(donation)
        klasses = ["authorization-status-#{donation.authorization_status}"]
        klasses << "checkout-status-success" if donation.success?
        klasses.join(" ")
      end

      def total_donations
        donations.count
      end

      def total_donations_successful
        donations.where(success: true).count
      end

      def total_donations_amount
        donations.where(success: true).sum(:amount).to_f / 100
      end
    end
  end
end
