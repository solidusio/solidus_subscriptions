class SolidusSubscriptions::Api::V1::SubscriptionsController < Spree::Api::BaseController
  before_filter :load_subscription, only: [:cancel, :update, :skip]

  def update
    if @subscription.update(subscription_params)
      render json: @subscription.to_json(include: :line_item)
    else
      render json: @subscription.errors.to_json, status: 422
    end
  end

  def skip
    if @subscription.advance_actionable_date
      render json: @subscription.to_json
    else
      render json: @subscription.errors.to_json, status: 422
    end
  end

  def cancel
    if @subscription.cancel
      render json: @subscription.to_json
    else
      render json: @subscription.errors.to_json, status: 422
    end
  end

  private

  def load_subscription
    @subscription = current_api_user.subscriptions.find(params[:id])
  end

  def subscription_params
    params.require(:subscription).permit(
      line_item_attributes: line_item_attributes
    )
  end

  def line_item_attributes
    SolidusSubscriptions::Config.subscription_line_item_attributes - [:subscribable_id] + [:id]
  end
end
