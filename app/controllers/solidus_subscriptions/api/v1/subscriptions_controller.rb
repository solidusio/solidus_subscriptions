class SolidusSubscriptions::Api::V1::SubscriptionsController < Spree::Api::BaseController
  before_filter :load_subscription, only: :cancel

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
end
