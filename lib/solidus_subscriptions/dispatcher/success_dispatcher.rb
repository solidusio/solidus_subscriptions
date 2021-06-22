# frozen_string_literal: true

module SolidusSubscriptions
  module Dispatcher
    class SuccessDispatcher < Base
      def dispatch
        installment.success!(order)
      end
    end
  end
end
