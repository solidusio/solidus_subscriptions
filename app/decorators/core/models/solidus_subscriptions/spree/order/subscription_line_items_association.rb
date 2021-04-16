# frozen_string_literal: true

# Spree::Orders may contain many subscription_line_items. When the order is
# finalized these subscription_line_items are converted into subscritpions.
# The order needs to be able to get a list of associated subscription_line_items
# to be able to populate the full subscriptions.
module SolidusSubscriptions
  module Spree
    module Order
      module SubscriptionLineItemsAssociation
        def self.prepended(base)
          base.has_many :subscription_line_items, through: :line_items
        end
      end
    end
  end
end

Spree::Order.prepend(SolidusSubscriptions::Spree::Order::SubscriptionLineItemsAssociation)
