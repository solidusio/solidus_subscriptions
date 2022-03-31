# frozen_string_literal: true

# This module is responsible for taking SolidusSubscriptions::LineItem
# objects and creating SolidusSubscriptions::Subscription Objects
module SolidusSubscriptions
  class SubscriptionGenerator
    SubscriptionConfiguration = Struct.new(:interval_length, :interval_units, :end_date)

    # From an order, group subscription line items by common subscription
    # configuration options and create subscriptions. Grouped subscription_line_items
    # can belong to a single subscription.
    #
    # @param order [Spree::Order] The order with subscription line items
    #
    # @return [Array<SolidusSubscriptions::Subscription>] Array of subscriptions
    def self.from_order(order)
      line_items_by_configuration = order.subscription_line_items.group_by do |subscription_line_item|
        subscription_configuration(subscription_line_item)
      end

      line_items_by_configuration.map do |configuration, subscription_line_items_group|
        new(subscription_line_items: subscription_line_items_group, order: order, subscription_attributes: configuration).activate
      end
    end

    def self.subscription_configuration(subscription_line_item)
      SubscriptionConfiguration.new(
        subscription_line_item.interval_length,
        subscription_line_item.interval_units,
        subscription_line_item.end_date
      )
    end

    attr_reader :subscription_line_items, :order

    def initialize(subscription_line_items:, order:, subscription_attributes:)
      @subscription_line_items = subscription_line_items
      @order = order
      @subscription_attributes = subscription_attributes.to_h
    end

    # Create and persist a subscription for a collection of subscription
    # line items
    #
    # @return [SolidusSubscriptions::Subscription]
    def activate
      subscription = build_subscription
      subscription.save!
      cleanup_subscription_line_items
      subscription
    end

    private

    def build_subscription
      return if subscription_line_items.empty?

      if order.nil?
        ActiveSupport::Deprecation.warn("DEPRECATED: Please provide an order")
      end
      order ||= subscription_line_items.first.order

      payment_source = find_payment_source
      payment_method = payment_source&.payment_method

      subscription = Subscription.new(
        user: order.user,
        line_items: subscription_line_items,
        store: order.store,
        shipping_address: order.ship_address,
        billing_address: order.bill_address,
        payment_source: payment_source,
        payment_method: payment_method,
        currency: order.currency,
        **@subscription_attributes
      )
      subscription.actionable_date = subscription.next_actionable_date
      subscription
    end

    def find_payment_source
      order.payments.valid&.last&.source || (
        order.user && (
          order.user.wallet.default_wallet_payment_source&.payment_source ||
          order.user.wallet_payment_sources.last&.payment_source
        )
      )
    end

    def cleanup_subscription_line_items
      ids = subscription_line_items.pluck :id
      SolidusSubscriptions::LineItem.where(id: ids).update_all(
        interval_length: nil,
        interval_units: nil,
        end_date: nil
      )
    end
  end
end
