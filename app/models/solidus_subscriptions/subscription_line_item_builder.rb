module SolidusSubscriptions
  module SubscriptionLineItemBuilder
    private

    def create_subscription_line_item(line_item)
      SolidusSubscriptions::LineItem.create!(
        subscription_params.merge(spree_line_item: line_item)
      )

      # Rerun the promotion handler to pickup subscription promotions
      Spree::PromotionHandler::Cart.new(line_item.order).activate
      if Spree.solidus_gem_version >= Gem::Version.new('2.4.0')
        line_item.order.recalculate
      else
        line_item.order.update!
      end
    end

    def subscription_params
      params.require(:subscription_line_item).permit(
        SolidusSubscriptions::Config.subscription_line_item_attributes
      )
    end
  end
end
