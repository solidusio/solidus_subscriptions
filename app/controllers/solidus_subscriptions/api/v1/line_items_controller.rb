class SolidusSubscriptions::Api::V1::LineItemsController < Spree::Api::BaseController
  before_filter :load_line_item, only: :update

  def update
    return render json: {}, status: 404 unless @line_item.order.user == current_api_user

    if @line_item.update(line_item_params)
      render json: @line_item.to_json
    else
      render json: @line_item.errors.to_json, status: 422
    end
  end

  private

  def line_item_params
    params.require(:subscription_line_item).permit(
      SolidusSubscriptions::Config.subscription_line_item_attributes - [:subscribable_id]
    )
  end

  def load_line_item
    @line_item = SolidusSubscriptions::LineItem.find(params[:id])
  end
end
