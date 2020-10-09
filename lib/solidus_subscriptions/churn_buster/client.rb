# frozen_string_literal: true

module SolidusSubscriptions
  module ChurnBuster
    class Client
      BASE_API_URL = 'https://api.churnbuster.io/v1'

      attr_reader :account_id, :api_key

      def initialize(account_id:, api_key:)
        @account_id = account_id
        @api_key = api_key
      end

      def report_failed_payment(order)
        post('/failed_payments', OrderSerializer.serialize(order))
      end

      def report_successful_payment(order)
        post('/successful_payments', OrderSerializer.serialize(order))
      end

      def report_subscription_cancellation(subscription)
        post('/cancellations', SubscriptionSerializer.serialize(subscription))
      end

      def report_payment_method_change(subscription)
        post('/payment_methods', SubscriptionPaymentMethodSerializer.serialize(subscription))
      end

      private

      def post(path, body)
        HTTParty.post(
          "#{BASE_API_URL}#{path}",
          body: body.to_json,
          headers: {
            'Content-Type' => 'application/json',
          },
          basic_auth: {
            username: account_id,
            password: api_key,
          },
        )
      end
    end
  end
end
