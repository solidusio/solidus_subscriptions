# frozen_string_literal: true

# Handles payment failures for subscription installments.
module SolidusSubscriptions
  module Dispatcher
    class PaymentFailedDispatcher < Base
      def dispatch
        order.touch(:completed_at)
        order.cancel
        installments.each do |installment|
          installment.payment_failed!(order)
        end

        ::Spree::Event.fire(
          'solidus_subscriptions.installments_failed_payment',
          installments: installments,
          order: order,
        )
      end
    end
  end
end
