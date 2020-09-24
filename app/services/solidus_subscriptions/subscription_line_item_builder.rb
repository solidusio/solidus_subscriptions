# frozen_string_literal: true

module SolidusSubscriptions
  module SubscriptionLineItemBuilder
    private

    def create_subscription_line_item(line_item)
      SolidusSubscriptions::LineItem.create!(
        subscription_params.merge(spree_line_item: line_item)
      )

      # Rerun the promotion handler to pickup subscription promotions
      ::Spree::PromotionHandler::Cart.new(line_item.order).activate
      line_item.order.recalculate
    end

    def subscription_params
      params.require(:subscription_line_item).permit(
        SolidusSubscriptions.configuration.subscription_line_item_attributes
      )
    end
  end
end
