# frozen_string_literal: true

module SolidusSubscriptions
  module Api
    module V1
      class LineItemsController < ::Spree::Api::BaseController
        before_action :load_line_item, only: [:update, :destroy]
        wrap_parameters :subscription_line_item

        def update
          authorize! :update, @line_item
          if @line_item.update(line_item_params)
            render json: @line_item.to_json
          else
            render json: @line_item.errors.to_json, status: :unprocessable_entity
          end
        end

        def destroy
          authorize! :destroy, @line_item
          return render json: {}, status: :bad_request if @line_item.order.complete?

          @line_item.destroy!
          @line_item.order.recalculate

          render json: @line_item.to_json
        end

        private

        def line_item_params
          params.require(:subscription_line_item).permit(
            SolidusSubscriptions::PermittedAttributes.subscription_line_item_attributes - [:subscribable_id]
          )
        end

        def load_line_item
          @line_item = SolidusSubscriptions::LineItem.find(params[:id])
        end
      end
    end
  end
end
