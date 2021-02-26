# frozen_string_literal: true

# This module is responsible for taking SolidusSubscriptions::LineItem
# objects and creating SolidusSubscriptions::Subscription Objects
module SolidusSubscriptions
  module SubscriptionGenerator
    extend self

    SubscriptionConfiguration = Struct.new(:interval_length, :interval_units, :end_date)

    # Create and persist a subscription for a collection of subscription
    #   line items
    #
    # @param subscription_line_items [Array<SolidusSubscriptions::LineItem>] The
    #   subscription_line_items to be activated
    #
    # @return [SolidusSubscriptions::Subscription]
    def activate(subscription_line_items)
      return if subscription_line_items.empty?

      order = subscription_line_items.first.order
      configuration = subscription_configuration(subscription_line_items.first)

      subscription_attributes = {
        user: order.user,
        line_items: subscription_line_items,
        store: order.store,
        shipping_address: order.ship_address,
        billing_address: order.bill_address,
        payment_source: order.payments.valid.last&.payment_source,
        payment_method: order.payments.valid.last&.payment_method,
        currency: order.currency,
        **configuration.to_h
      }

      Subscription.create!(subscription_attributes) do |sub|
        sub.actionable_date = sub.next_actionable_date
      end.tap do |_subscription|
        cleanup_subscription_line_items(subscription_line_items)
      end
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
