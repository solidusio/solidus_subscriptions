# frozen_string_literal: true

module SolidusSubscriptions
  module Dispatcher
    class PaymentFailedDispatcher < Base
      def dispatch
        order.touch(:completed_at)
        order.cancel
        installment.payment_failed!(order)

        ::Spree::Event.fire(
          'solidus_subscriptions.installment_failed_payment',
          installment: installment,
          order: order,
        )
      end
    end
  end
end
