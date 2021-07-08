# frozen_string_literal: true

require "decidim/core/test/factories"

FactoryBot.define do
  factory :donation, class: "Decidim::Donations::Donation" do
    amount { Faker::Number.number(digits: 2) }
    reference { Faker::Invoice.reference }
    user { build(:user) }
    title { I18n.t("checkout.title", name: user.name, scope: "decidim.donations") }
    description { I18n.t("checkout.description", organization: user.organization.name, scope: "decidim.donations") }
    success { true }
    params { { transaction_id: reference, payer_id: Faker::Invoice.reference } }
  end
end
