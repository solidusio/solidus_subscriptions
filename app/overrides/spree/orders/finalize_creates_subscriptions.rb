# Once an order is finalized its subscriptions line items should be converted
# into active subscritptions. This hooks into Spree::Order#finalize! and
# passes all subscription_line_items present on the order to the Subscription
# generator which will build and persist the subscriptions
module Spree
  module Orders
    module FinalizeCreatesSubscriptions
      def finalize!
        SolidusSubscriptions::SubscriptionGenerator.activate(subscription_line_items)
        super
      end
    end
  end
end

Spree::Order.prepend Spree::Orders::FinalizeCreatesSubscriptions
