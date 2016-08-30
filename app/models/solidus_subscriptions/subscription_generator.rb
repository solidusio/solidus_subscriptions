# This module is responsible for taking SolidusSubscriptions::LineItem
# objects and creating SolidusSubscriptions::Subscription Objects
module SolidusSubscriptions
  module SubscriptionGenerator
    # Create and persist a collection of subscriptions
    #
    # @param [Array<SolidusSubscriptions::LineItem>] :subscription_line_items,
    #   The subscription_line_items to be activated
    #
    # @return [Array<SolidusSubscriptions::Subscription>]
    def self.activate(subscription_line_items)
      subscription_line_items.map do |subscription_line_item|
        user = subscription_line_item.order.user
        Subscription.create(user: user, line_item: subscription_line_item)
      end
    end
  end
end
