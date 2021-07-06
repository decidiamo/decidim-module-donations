# frozen_string_literal: true

module Decidim
  module Donations
    class CheckoutForm < AuthorizationHandler
      attribute :amount, Integer, default: Donations.config.default_amount
      attribute :token
      attribute :payer_id

      validates :amount, numericality: { greater_than_or_equal_to: Donations.config.minimum_amount }, unless: ->(form) { form.token }

      def order
        {
          amount: amount,
          ip: context.ip,
          return_url: context.return_url,
          cancel_return_url: context.cancel_return_url,
          currency: Donations.currency,
          title: context.title,
          description: context.description
        }
      end
    end
  end
end
