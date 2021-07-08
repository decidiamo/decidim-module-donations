# frozen_string_literal: true

module Decidim
  module Donations
    class PayOrder < Rectify::Command
      def initialize(form, provider)
        @form = form
        @provider = provider
      end

      def call
        return broadcast(:invalid) unless form.valid?

        begin
          perform_payment!
          save_payment!
          broadcast(:ok, response)
        rescue PaymentError => e
          broadcast(:invalid, e.message)
        end
      end

      private

      attr_reader :form, :provider, :response

      def perform_payment!
        @response = provider.purchase(order: form.order, params: form.attributes)
      end

      def save_payment!
        Donation.create!(
          amount: provider.amount_in_cents,
          reference: provider.transaction_id,
          title: form.order[:title],
          description: form.order[:description],
          success: response.success?,
          params: response.params,
          method: provider.method,
          user: form.current_user
        )
      end
    end
  end
end
