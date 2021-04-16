# frozen_string_literal: true

module SolidusSubscriptions
  module Spree
    module Order
      module SubscriptionAssociation
        def self.prepended(base)
          base.belongs_to :subscription, class_name: '::SolidusSubscriptions::Subscription', optional: true
        end
      end
    end
  end
end

Spree::Order.prepend(SolidusSubscriptions::Spree::Order::SubscriptionAssociation)
