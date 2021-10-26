module SolidusSubscriptions
  class DisableSubscriptionOrderPromotionRule < Spree::PromotionRule
    def applicable?(promotable)
      promotable.is_a?(Spree::Order)
    end

    def eligible?(_order, **_options)
      true
    end

    def actionable?(line_item)
      !line_item.order.subscription_order? && line_item.subscription_line_items.none?
    end
  end
end
