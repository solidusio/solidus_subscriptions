# Create new subscription line items associated to the current order, when
# a line item is added to the cart which includes subscription_line_item
# params.
#
# The Subscriptions::LineItem acts as a line item place holder for a
# Subscription, indicating that it has been added to the order, but not
# yet purchased
module Spree
  module Controllers
    module Orders
      module CreateSubscriptionLineItems
        def self.prepended(base)
          base.after_action(
            :create_subscription_line_item,
            only: :populate,
            if: ->{ params[:subscription_line_item] }
          )
        end

        private

        def create_subscription_line_item
          SolidusSubscriptions::LineItem.create!(
            subscription_params.merge(spree_line_item: line_item)
          )

          # Rerun the promotion handler to pickup subscription promotions
          Spree::PromotionHandler::Cart.new(current_order).activate
        end

        def line_item
          @current_order.line_items.find_by(variant_id: params[:variant_id])
        end
      end
    end
  end
end

Spree::OrdersController.prepend(Spree::Controllers::Orders::CreateSubscriptionLineItems)
