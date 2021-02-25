module SolidusSubscriptions
  class DisableSubscriptionOrderPromotionRule < Spree::PromotionRule

    def applicable?(promotable)
      promotable.is_a? Spree::Order
    end

    def eligible?(order, **_options)
      order.subscription_line_items.none?
    end

  end
end
