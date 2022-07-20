# frozen_string_literal: true

# Once an order is finalized its subscriptions line items should be converted
# into active subscriptions. This hooks into Spree::Order#finalize! and
# passes all subscription_line_items present on the order to the Subscription
# generator which will build and persist the subscriptions
module SolidusSubscriptions
  module Spree
    module Order
      module FinalizeCreatesSubscriptions
        method_name = Spree::Order.instance_methods.include?(:finalize) ? :finalize : :finalize!

        define_method(method_name) do
          SolidusSubscriptions::SubscriptionGenerator.call(self)
          super()
        end

        ::Spree::Order.prepend self
      end
    end
  end
end

