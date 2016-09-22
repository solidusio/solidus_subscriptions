# Accept parameters needed to build SolidusSubscriptions::LineItem objects
module Spree
  module Controllers
    module Orders
      module SubscriptionParams
        private

        def subscription_params
          params.require(:order).require(:subscription_line_item).permit(
            SolidusSubscriptions::Config.subscription_line_item_attributes
          )
        end
      end
    end
  end
end

Spree::OrdersController.prepend(Spree::Controllers::Orders::SubscriptionParams)

# Allow spree line items to accept nested attributes for subscritption line items
line_item_attributes = Spree::PermittedAttributes.line_item_attributes

subscription_line_item_attributes = {
  subscription_line_items_attributes: [
    SolidusSubscriptions::Config.subscription_line_item_attributes
  ]
}

Spree::PermittedAttributes.class_variable_set(
  '@@line_item_attributes',
  line_item_attributes << subscription_line_item_attributes
)
