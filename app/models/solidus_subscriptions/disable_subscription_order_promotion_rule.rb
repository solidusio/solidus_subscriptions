module SolidusSubscriptions
  class DisableSubscriptionOrderPromotionRule < Spree::PromotionRule

    def applicable?(promotable)
      promotable.is_a? Spree::Order
    end

    def eligible?(order, **_options)
      if order.subscription_line_items.any?
        false
      else
        true
      end
    end

  end
end
