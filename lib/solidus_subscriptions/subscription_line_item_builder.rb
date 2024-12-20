# frozen_string_literal: true

module SolidusSubscriptions
  module SubscriptionLineItemBuilder
    private

    def create_subscription_line_item(line_item)
      SolidusSubscriptions::LineItem.create!(
        subscription_params.merge(spree_line_item: line_item)
      )

      # Rerun the legacy promotion handler to pickup subscription promotions
      # `solidus_promotions` does not need this handler, and will pickup promotions in `order.recalculate`
      ::Spree::PromotionHandler::Cart.new(line_item.order).activate if defined?(::Spree::PromotionHandler::Cart)
      line_item.order.recalculate
    end

    def subscription_params
      params.require(:subscription_line_item).permit(
        SolidusSubscriptions.configuration.subscription_line_item_attributes
      )
    end
  end
end
