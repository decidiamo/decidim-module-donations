# frozen_string_literal: true

module Decidim
  module Donations
    class Donation < ApplicationRecord
      self.table_name = :decidim_donations_donations

      belongs_to :user, foreign_key: "decidim_user_id", class_name: "Decidim::User"
    end
  end
end
