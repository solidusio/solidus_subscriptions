# frozen_string_literal: true

module SolidusSubscriptions
  module Promotion
    module Rules
      class SubscriptionInstallmentOrder < ::Spree::PromotionRule
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

        # An order is eligible if it fulfills a subscription Installment. Will only
        # return true if the order fulfills one or more Installments
        #
        # @param order [Spree::Order] The order which could have this rule applied
        #   to it.
        #
        # @return [Boolean]
        def eligible?(order, **_options)
          order.subscription_order?
        end
      end
    end
  end
end
