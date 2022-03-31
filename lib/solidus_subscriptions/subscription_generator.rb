# frozen_string_literal: true

# This module is responsible for taking SolidusSubscriptions::LineItem
# objects and creating SolidusSubscriptions::Subscription Objects
module SolidusSubscriptions
  module SubscriptionGenerator
    extend self

    SubscriptionConfiguration = Struct.new(:interval_length, :interval_units, :end_date)

    def from_order(order)
      group(order.subscription_line_items).each do |subscription_line_items_group|
        activate(subscription_line_items_group, order: order)
      end

      order.reload
    end

    # Create and persist a subscription for a collection of subscription
    # line items
    #
    # @return [SolidusSubscriptions::Subscription]
    def activate(subscription_line_items, order: nil)
      return if subscription_line_items.empty?

      if order.nil?
        warn "DEPRECATED: Please provide an order", uplevel: 1
        order = subscription_line_items.first.order
      end

      payment_source = payment_source_for(subscription_line_items, order: order)
      payment_method = payment_source&.payment_method

      configuration = subscription_configuration(subscription_line_items.first)

      subscription_attributes = {
        user: order.user,
        line_items: subscription_line_items,
        store: order.store,
        shipping_address: order.ship_address,
        billing_address: order.bill_address,
        payment_source: payment_source,
        payment_method: payment_method,
        currency: order.currency,
        **configuration.to_h
      }

      Subscription.create!(subscription_attributes) do |sub|
        sub.actionable_date = sub.next_actionable_date
      end.tap do |_subscription|
        cleanup_subscription_line_items(subscription_line_items)
      end
    end

    def payment_source_for(subscription_line_items, order:)
      order.payments.valid&.last&.source || (
        order.user && (
          order.user.wallet.default_wallet_payment_source ||
          order.user.wallet_payment_sources.last
        )
      )
    end

    # Group a collection of line items by common subscription configuration
    # options. Grouped subscription_line_items can belong to a single
    # subscription.
    #
    # @param subscription_line_items [Array<SolidusSubscriptions::LineItem>] The
    #   subscription_line_items to be grouped.
    #
    # @return [Array<Array<SolidusSubscriptions::LineItem>>]
    def group(subscription_line_items)
      subscription_line_items.group_by do |li|
        subscription_configuration(li)
      end.
        values
    end

    private

    def cleanup_subscription_line_items(subscription_line_items)
      ids = subscription_line_items.pluck :id
      SolidusSubscriptions::LineItem.where(id: ids).update_all(
        interval_length: nil,
        interval_units: nil,
        end_date: nil
      )
    end

    def subscription_configuration(subscription_line_item)
      SubscriptionConfiguration.new(
        subscription_line_item.interval_length,
        subscription_line_item.interval_units,
        subscription_line_item.end_date
      )
    end
  end
end
