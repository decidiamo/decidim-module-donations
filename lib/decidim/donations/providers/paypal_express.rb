# frozen_string_literal: true

require "active_merchant"

module Decidim
  module Donations
    module Providers
      class PaypalExpress < AbstractProvider
        def initialize(login:, password:, signature:)
          @gateway = ActiveMerchant::Billing::PaypalExpressGateway.new({
                                                                         login: login,
                                                                         password: password,
                                                                         signature: signature
                                                                       })
        end

        # if multistep, requires a second action from the application to confirm the purchase
        def multistep?
          true
        end

        # depending on the provider the setup_purchase might have different parameters
        # only called on multistep providers
        def setup_purchase(order:, params: {})
          @amount = params[:amount]
          gateway.setup_purchase(amount_in_cents, options(order, amount_in_cents))
        end

        def purchase(order:, params: {})
          payment = gateway.details_for(params[:token])
          raise PaymentError, "Invalid token" unless payment.success?

          @amount = payment.details["OrderTotal"].to_f
          options(order, amount_in_cents, token: payment.token, payer_id: payment.payer_id)
          response = gateway.purchase(amount_in_cents, @order)
          raise PaymentError, response.message unless response.success?

          @transaction_id = response.params["transaction_id"]
          response
        end

        private

        def options(order, amount, params = {})
          @order = order.except(:title, :description).merge(
            allow_guest_checkout: true,
            amount: amount,
            items: [{
              name: order[:title],
              description: order[:description],
              quantity: "1",
              number: "1",
              amount: amount
            }]
          ).merge(params)
        end
      end
    end
  end
end
