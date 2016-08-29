module Spree
  module Controllers
    module Orders
      module SubscriptionParams
        private

        def subscription_params
          params.require(:subscription_line_item).permit(
            :quantity,
            :subscribable_id,
            :interval,
            :max_installments
          )
        end
      end
    end
  end
end

Spree::OrdersController.prepend(Spree::Controllers::Orders::SubscriptionParams)
