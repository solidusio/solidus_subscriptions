class SolidusSubscriptions::Api::V1::LineItemsController < Spree::Api::BaseController
  before_action :load_line_item, only: [:update, :destroy]
  wrap_parameters :subscription_line_item

  def update
    authorize! :crud, @line_item, @order
    if @line_item.update(line_item_params)
      render json: @line_item.to_json
    else
      render json: @line_item.errors.to_json, status: 422
    end
  end

  def destroy
    authorize! :crud, @line_item, @order
    return render json: {}, status: 400 if @line_item.order.complete?

    @line_item.destroy!
    @line_item.order.update!

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
