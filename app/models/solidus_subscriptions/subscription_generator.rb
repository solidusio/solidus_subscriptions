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

      user = subscription_line_items.first.order.user
      store = subscription_line_items.first.order.store

      Subscription.create!(user: user, line_items: subscription_line_items, store: store) do |sub|
        sub.actionable_date = sub.next_actionable_date
      end
    end
  end
end
