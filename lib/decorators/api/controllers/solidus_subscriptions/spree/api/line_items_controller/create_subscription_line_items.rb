# frozen_string_literal: true

# Create new subscription line items associated to the current order, when
# a line item is added to the cart which includes subscription_line_item
# params.
#
# The Subscriptions::LineItem acts as a line item place holder for a
# Subscription, indicating that it has been added to the order, but not
# yet purchased
module SolidusSubscriptions
  module Spree
    module Api
      module LineItemsController
        module CreateSubscriptionLineItems
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

          def line_items_attributes
            super.tap do |attrs|
              if params[:subscription_line_items_attributes]
                attrs[:line_items_attributes].merge!(
                  subscription_line_items_attributes: subscription_line_item_params
                )
              end
            end
          end

          def subscription_line_item_params
            params[:subscription_line_items_attributes].permit(SolidusSubscriptions::PermittedAttributes.subscription_line_item_attributes)
          end
        end
      end
    end
  end
end

Spree::Api::LineItemsController.prepend(SolidusSubscriptions::Spree::Api::LineItemsController::CreateSubscriptionLineItems)
