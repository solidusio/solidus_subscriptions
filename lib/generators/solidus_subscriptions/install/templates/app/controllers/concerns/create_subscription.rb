# frozen_string_literal: true

module CreateSubscription
  extend ActiveSupport::Concern
  include SolidusSubscriptions::SubscriptionLineItemBuilder

  included do
    after_action :handle_subscription_line_items, only: :create, if: :subscription_line_item_params_present?
  end

  private

  def handle_subscription_line_items
    line_item = @current_order.line_items.find_by(variant_id: params[:variant_id])
    create_subscription_line_item(line_item)
  end

  def subscription_params
    params.fetch(:subscription_line_item, {})
  end

  def subscription_line_item_params_present?
    subscription_params[:subscribable_id].present? &&
      subscription_params[:quantity].present? &&
      subscription_params[:interval_length].present?
  end
end
