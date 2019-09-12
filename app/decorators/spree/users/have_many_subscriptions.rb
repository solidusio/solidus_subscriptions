# Spree::Users maintain a list of the subscriptions associated with them
module Spree
  module Users
    module HaveManySubscriptions
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

Spree.user_class.prepend(Spree::Users::HaveManySubscriptions)
