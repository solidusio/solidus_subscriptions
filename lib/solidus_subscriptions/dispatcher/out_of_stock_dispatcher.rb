# frozen_string_literal: true

module SolidusSubscriptions
  module Dispatcher
    class OutOfStockDispatcher < Base
      def dispatch
        installment.out_of_stock
      end
    end
  end
end
