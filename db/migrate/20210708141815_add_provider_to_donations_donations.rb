# frozen_string_literal: true

class AddProviderToDonationsDonations < ActiveRecord::Migration[5.2]
  def change
    add_column :decidim_donations_donations, :method, :string
  end
end
