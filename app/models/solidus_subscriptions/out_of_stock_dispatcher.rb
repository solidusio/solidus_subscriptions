# This service class is intented to provide callback behaviour to handle
# the case where an installment cannot be processed due to lack of stock.
module SolidusSubscriptions
  class OutOfStockDispatcher
    attr_reader :installments

    def initialize(*installments)
      @installments = installments
    end

    def dispatch
      installments.each(&:out_of_stock)
      log_failure
    end

    private

    def log_failure
      # Tell someone stuff was out of stock
    end
  end
end
