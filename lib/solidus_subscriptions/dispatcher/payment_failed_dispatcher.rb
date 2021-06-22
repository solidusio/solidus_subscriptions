# frozen_string_literal: true

module SolidusSubscriptions
  module Dispatcher
    class PaymentFailedDispatcher < Base
      def dispatch
        order.touch(:completed_at)
        order.cancel
        installment.payment_failed!(order)
      end
    end
  end
end
