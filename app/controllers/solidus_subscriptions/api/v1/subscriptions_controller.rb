class SolidusSubscriptions::Api::V1::SubscriptionsController < Spree::Api::BaseController
  before_action :load_subscription, only: [:cancel, :update, :skip]

  def update
    if @subscription.update(subscription_params)
      render json: @subscription.to_json(include: [:line_items, :shipping_address, :billing_address, :wallet_payment_source])
    else
      render json: @subscription.errors.to_json, status: 422
    end
  end

  def skip
    if @subscription.skip
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
      :email,
      :actionable_date,
      line_items_attributes: line_item_attributes,
      shipping_address_attributes: Spree::PermittedAttributes.address_attributes,
      billing_address_attributes: Spree::PermittedAttributes.address_attributes,
      wallet_payment_source_attributes: [:user_id, payment_source_attributes: [:source_type, :nonce, :payment_type, :payment_method_id]]
    )
  end

  def line_item_attributes
    SolidusSubscriptions::Config.subscription_line_item_attributes - [:subscribable_id] + [:id]
  end
end
