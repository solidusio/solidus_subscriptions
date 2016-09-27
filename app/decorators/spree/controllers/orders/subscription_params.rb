# Accept parameters needed to build SolidusSubscriptions::LineItem objects
module Spree
  module Controllers
    module Orders
      module SubscriptionParams
        private

        def subscription_params
          params.require(:subscription_line_item).permit(
            SolidusSubscriptions::Config.subscription_line_item_attributes
          )
        end
      end
    end
  end
end

Spree::OrdersController.prepend(Spree::Controllers::Orders::SubscriptionParams)
