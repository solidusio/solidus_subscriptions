class SolidusSubscriptions::Api::V1::LineItemsController < Spree::Api::BaseController
  before_filter :load_line_item, only: :update

  def update
    if @line_item.update(line_item_params)
      render json: @line_item.to_json
    else
      render json: @line_item.errors.to_json, status: 422
    end
  end

  private

  def line_item_params
    params.require(:subscription_line_item).permit(
      :max_installments,
      :interval,
      :quantity
    )
  end

  def load_line_item
    @line_item = SolidusSubscriptions::LineItem.find(params[:id])
  end
end
