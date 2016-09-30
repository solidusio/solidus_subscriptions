# This service class is intented to provide callback behaviour to handle
# the case where an installment cannot be processed due to lack of stock.
module SolidusSubscriptions
  class OutOfStockDispatcher < Dispatcher
    def dispatch
      installments.each(&:out_of_stock)
      super
    end

    private

    def message
      "
      The following installemnts cannot be fulfilled due to lack of stock:
      #{installments.map(&:id).join(', ')}.
      "
    end
  end
end
