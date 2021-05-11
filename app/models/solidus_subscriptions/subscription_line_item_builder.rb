module SolidusSubscriptions
  module SubscriptionLineItemBuilder
    private

    def create_subscription_line_item(line_item)
      subscription_params[:subscribable_id].split(" ").each do |subscribable_id|
        merged_params = subscription_params.merge(spree_line_item: line_item)
        merged_params["subscribable_id"] = subscribable_id
        SolidusSubscriptions::LineItem.create!(merged_params)
      end


      # Rerun the promotion handler to pickup subscription promotions
      Spree::PromotionHandler::Cart.new(line_item.order).activate
      line_item.order.update!
    end

    def subscription_params
      params.require(:subscription_line_item).permit(
        SolidusSubscriptions::Config.subscription_line_item_attributes
      )
    end
  end
end
