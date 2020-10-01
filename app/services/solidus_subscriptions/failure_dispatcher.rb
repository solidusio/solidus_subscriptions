# frozen_string_literal: true

# Handles failed installments.
module SolidusSubscriptions
  class FailureDispatcher < Dispatcher
    def dispatch
      order.touch(:completed_at)
      order.cancel
      installments.each do |installment|
        installment.failed!(order)
      end
    end
  end
end
