module SolidusSubscriptions
  module SubscriptionLineItemBuilder
    private

    def create_subscription_line_item(line_item)
      SolidusSubscriptions::LineItem.create!(
        subscription_params.merge(spree_line_item: line_item)
      )

      # Rerun the promotion handler to pickup subscription promotions
      Spree::PromotionHandler::Cart.new(line_item.order).activate
    end

    def subscription_params
      params.require(:subscription_line_item).permit(
        SolidusSubscriptions::Config.subscription_line_item_attributes
      )
    end
  end
end
