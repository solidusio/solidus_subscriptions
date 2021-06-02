# Spree::Users maintain a list of the subscriptions associated with them
module SolidusSubscriptions
  module UserDecorator
    def self.prepended(base)
      base.has_many(
        :subscriptions,
        class_name: 'SolidusSubscriptions::Subscription',
        foreign_key: 'user_id'
      )

      base.accepts_nested_attributes_for :subscriptions
    end

    ::Spree.user_class.prepend(self)
  end
end

