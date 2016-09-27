class SolidusSubscriptions::Api::V1::LineItemsController < Spree::Api::BaseController
  before_filter :load_line_item, only: [:update, :destroy]
  wrap_parameters :subscription_line_item

  def update
    authorize! :manage, @line_item
    if @line_item.update(line_item_params)
      render json: @line_item.to_json
    else
      render json: @line_item.errors.to_json, status: 422
    end
  end

  def destroy
    authorize! :manage, @line_item
    return render json: {}, status: 400 if @line_item.order.complete?
    if @line_item.destroy
      render json: @line_item.to_json
    else
      render json: @line_item.errors.to_json, status: 500
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
