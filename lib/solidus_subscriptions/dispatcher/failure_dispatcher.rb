# frozen_string_literal: true

module SolidusSubscriptions
  module Dispatcher
    class FailureDispatcher < Base
      def dispatch
        order.touch(:completed_at)
        order.cancel
        installment.failed!(order)
      end
    end
  end
end
