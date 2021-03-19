# frozen_string_literal: true

module SolidusSubscriptions
  module Promotion
    module Rules
      class SubscriptionCreationOrder < ::Spree::PromotionRule
        # Promotion can be applied to an entire order. Will only be true
        # for Spree::Order
        #
        # @param promotable [Object] Any object which could have this
        #   promotion rule applied to it.
        #
        # @return [Boolean]
        def applicable?(promotable)
          promotable.is_a? ::Spree::Order
        end

        # An order is eligible if it contains a line item with an associates
        # subscription_line_item.  This rule applies to order and so its eligibility
        # will always be considered against an order. Will only return true for
        # orders containing Spree::Line item with associated subscription_line_items
        #
        # @param order [Spree::Order] The order which could have this rule applied
        #   to it.
        #
        # @return [Boolean]
        def eligible?(order, **_options)
          order.subscription_line_items.any?
        end

        # Certain actions create adjustments on line items. In this case, only
        # line items with associated subscription_line_items are eligible to be
        # adjusted. Will only return true # if :line_item has an associated
        # subscription.
        #
        # @param line_item [Spree::LineItem] The line item which could be adjusted
        #   by the promotion.
        def actionable?(line_item)
          line_item.subscription_line_items.present?
        end
      end
    end
  end
end
