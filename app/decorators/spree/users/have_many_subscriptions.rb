# Spree::Users maintain a list of the subscriptions associated with them
module Spree
  module Users
    module HaveManySubscritptions
      def self.prepended(base)
        base.has_many(
          :subscriptions,
          class_name: 'SolidusSubscriptions::Subscription',
          foreign_key: 'user_id'
        )

        base.accepts_nested_attributes_for :subscriptions
      end
    end
  end
end

Spree.user_class.prepend(Spree::Users::HaveManySubscritptions)

user_attributes = Spree::PermittedAttributes.user_attributes

subscription_attributes = {
  subscriptions_attributes: {
    line_item_attributes: SolidusSubscriptions::Config.subscription_line_item_attributes
  }
}

Spree::PermittedAttributes.class_variable_set(
  '@@user_attributes',
  user_attributes << subscription_attributes
)
