# frozen_string_literal: true

module SolidusSubscriptions
  class Checkout
    attr_reader :installment

    def initialize(installment)
      @installment = installment
    end

    def process
      order = create_order

      begin
        populate_order(order)
        finalize_order(order)

        SolidusSubscriptions.configuration.success_dispatcher_class.new(installment, order).dispatch
      rescue StateMachines::InvalidTransition
        if order.payments.any?(&:failed?)
          SolidusSubscriptions.configuration.payment_failed_dispatcher_class.new(installment, order).dispatch
        else
          SolidusSubscriptions.configuration.failure_dispatcher_class.new(installment, order).dispatch
        end
      rescue ::Spree::Order::InsufficientStock
        SolidusSubscriptions.configuration.out_of_stock_dispatcher_class.new(installment, order).dispatch
      end

      order
    end

    private

    def create_order
      ::Spree::Order.create(
        user: installment.subscription.user,
        email: installment.subscription.user.email,
        store: installment.subscription.store || ::Spree::Store.default,
        subscription_order: true,
        subscription: installment.subscription,
        currency: installment.subscription.currency
      )
    end

    def populate_order(order)
      installment.subscription.line_items.each do |line_item|
        order.contents.add(line_item.subscribable, line_item.quantity)
      end
    end

    def finalize_order(order)
      ::Spree::PromotionHandler::Cart.new(order).activate
      order.recalculate

      order.checkout_steps[0...-1].each do
        case order.state
        when 'address'
          order.ship_address = installment.subscription.shipping_address_to_use
          order.bill_address = installment.subscription.billing_address_to_use
        when 'payment'
          order.payments.create(
            payment_method: installment.subscription.payment_method_to_use,
            source: installment.subscription.payment_source_to_use,
            amount: order.total,
          )
        end

        order.next!
      end

      order.complete!
    end
  end
end
