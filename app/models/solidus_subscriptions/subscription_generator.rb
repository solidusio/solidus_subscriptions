# This module is responsible for taking SolidusSubscriptions::LineItem
# objects and creating SolidusSubscriptions::Subscription Objects
module SolidusSubscriptions
  module SubscriptionGenerator
    # Create and persist a subscription for a collection of subscription
    #   line items
    #
    # @param subscription_line_items [Array<SolidusSubscriptions::LineItem>] The
    #   subscription_line_items to be activated
    #
    # @return [SolidusSubscriptions::Subscription]
    def self.activate(subscription_line_items)
      return if subscription_line_items.empty?

      order = subscription_line_items.first.order

      subscription_attributes = {
        user: order.user,
        line_items: subscription_line_items,
        store: order.store,
        shipping_address: order.ship_address
      }

      Subscription.create!(subscription_attributes) do |sub|
        sub.actionable_date = sub.next_actionable_date
      end
    end
  end
end
