# frozen_string_literal: true

# Handles installments that cannot be processed for lack of stock.
module SolidusSubscriptions
  module Dispatcher
    class OutOfStockDispatcher < Base
      def dispatch
        installments.each(&:out_of_stock)
      end
    end
  end
end
