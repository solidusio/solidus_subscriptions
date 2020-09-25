# frozen_string_literal: true

# Spree::Users maintain a list of the subscriptions associated with them
module SolidusSubscriptions
  module Spree
    module User
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
end

Spree.user_class.prepend(SolidusSubscriptions::Spree::User::HaveManySubscriptions)
