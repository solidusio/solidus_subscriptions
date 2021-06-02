# Each Spree::LineItem can have multiple subscription_line_items. This
# allows a cart to represent multiple subscriptions to the same item in
# the same order.
module SolidusSubscriptions
  module LineItemDecorator
    def self.prepended(base)
      base.has_many(
        :subscription_line_items,
        class_name: 'SolidusSubscriptions::LineItem',
        foreign_key: :spree_line_item_id,
        inverse_of: :spree_line_item,
        dependent: :destroy
      )

      base.accepts_nested_attributes_for :subscription_line_items
    end

    ::Spree::LineItem.prepend self
  end
end
