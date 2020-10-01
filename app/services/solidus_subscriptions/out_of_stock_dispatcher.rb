# frozen_string_literal: true

# Handles installments that cannot be processed for lack of stock.
module SolidusSubscriptions
  class OutOfStockDispatcher < Dispatcher
    def dispatch
      installments.each(&:out_of_stock)
    end
  end
end
