# frozen_string_literal: true

class CreateDonationsDonations < ActiveRecord::Migration[5.2]
  def change
    create_table :decidim_donations_donations do |t|
      t.integer :amount # in cents: 10€ == 1000
      t.string :reference
      t.string :title
      t.string :description
      t.boolean :success
      t.jsonb :params
      t.references :decidim_user, null: false, foreign_key: true, index: true

      t.timestamps
    end
  end
end
