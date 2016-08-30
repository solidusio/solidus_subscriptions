# Each Spree::LineItem can have multiple subscription_line_items. This
# allows a cart to represent multiple subscriptions to the same item in
# the same order.
module Spree
  module LineItems
    module SubscriptionLineItemsAssociation
      def self.prepended(base)
        base.has_many(
          :subscription_line_items,
          class_name: 'SolidusSubscriptions::LineItem',
          foreign_key: :spree_line_item_id
        )
      end
    end
  end
end

Spree::LineItem.prepend Spree::LineItems::SubscriptionLineItemsAssociation
