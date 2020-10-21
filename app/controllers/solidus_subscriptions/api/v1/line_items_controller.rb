# frozen_string_literal: true

module SolidusSubscriptions
  module Api
    module V1
      class LineItemsController < BaseController
        protect_from_forgery unless: -> { request.format.json? }

        wrap_parameters :subscription_line_item

        def update
          load_line_item

          if @line_item.update(line_item_params)
            render json: @line_item.to_json
          else
            render json: @line_item.errors.to_json, status: :unprocessable_entity
          end
        end

        def destroy
          load_line_item

          @line_item.destroy!

          if @line_item.order && !@line_item.order.complete?
            @line_item.order.recalculate
          end

          render json: @line_item.to_json
        end

        private

        def load_line_item
          @line_item = SolidusSubscriptions::LineItem.find(params[:id])
          authorize! action_name.to_sym, @line_item, subscription_guest_token
        end

        def line_item_params
          params.require(:subscription_line_item).permit(
            SolidusSubscriptions::PermittedAttributes.subscription_line_item_attributes - [:subscribable_id]
          )
        end
      end
    end
  end
end
