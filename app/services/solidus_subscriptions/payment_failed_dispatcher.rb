# frozen_string_literal: true

# Handles payment failures for subscription installments.
module SolidusSubscriptions
  class PaymentFailedDispatcher < Dispatcher
    def dispatch
      order.touch(:completed_at)
      order.cancel
      installments.each do |installment|
        installment.payment_failed!(order)
      end
    end
  end
end
