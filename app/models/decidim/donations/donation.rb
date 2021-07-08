# frozen_string_literal: true

module Decidim
  module Donations
    class Donation < ApplicationRecord
      self.table_name = :decidim_donations_donations

      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
      belongs_to :authorization,
                 foreign_key: "authorization_unique_id",
                 primary_key: "unique_id",
                 class_name: "Decidim::Authorization",
                 optional: true

      def provider_class
        Donations.find_provider_class method
      end

      def decimal_amount
        amount.to_f / 100
      end
    end
  end
end
