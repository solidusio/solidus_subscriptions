# frozen_string_literal: true

module SolidusSubscriptions
  module OrderRenewal
    class OrderCreator
      def initialize(subscription)
        @subscription = subscription
      end

      def call
        ::Spree::Order.create(
          user: subscription.user,
          email: subscription.user.email,
          store: subscription.store || Spree::Store.default,
          subscription_order: true,
          **extra_attributes
        )
      end

      private

      def extra_attributes
        {}
      end

      attr_reader :subscription
    end
  end
end
