# frozen_string_literal: true

module SolidusSubscriptions
  module Api
    module V1
      class SubscriptionsController < BaseController
        protect_from_forgery unless: -> { request.format.json? }

        def update
          load_subscription

          if @subscription.update(subscription_params)
            render json: @subscription.to_json(include: [:line_items, :shipping_address, :billing_address])
          else
            render json: @subscription.errors.to_json, status: :unprocessable_entity
          end
        end

        def skip
          load_subscription

          if @subscription.skip
            render json: @subscription.to_json
          else
            render json: @subscription.errors.to_json, status: :unprocessable_entity
          end
        end

        def cancel
          load_subscription

          if @subscription.cancel
            render json: @subscription.to_json
          else
            render json: @subscription.errors.to_json, status: :unprocessable_entity
          end
        end

        private

        def load_subscription
          @subscription = SolidusSubscriptions::Subscription.find(params[:id])
          authorize! action_name.to_sym, @subscription, subscription_guest_token
        end

        def subscription_params
          params.require(:subscription).permit(SolidusSubscriptions.configuration.subscription_attributes | [
            line_items_attributes: line_item_attributes,
          ])
        end

        def line_item_attributes
          SolidusSubscriptions.configuration.subscription_line_item_attributes - [:subscribable_id] + [:id]
        end
      end
    end
  end
end
