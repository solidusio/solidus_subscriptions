# Create new subscription line items associated to the current order, when
# a line item is added to the cart which includes subscription_line_item
# params.
#
# The Subscriptions::LineItem acts as a line item place holder for a
# Subscription, indicating that it has been added to the order, but not
# yet purchased
module Spree
  module Controllers::Api::LineItems::CreateSubscriptionLineItems
    include SolidusSubscriptions::SubscriptionLineItemBuilder

    def self.prepended(base)
      base.after_action(
        :handle_subscription_line_items,
        only: [:create, :update],
        if: ->{ params[:subscription_line_item] }
      )
    end

    private

    def handle_subscription_line_items
      create_subscription_line_item(@line_item)
    end
  end
end

Spree::Api::LineItemsController.prepend(Spree::Controllers::Api::LineItems::CreateSubscriptionLineItems)
