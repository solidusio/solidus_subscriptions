# This service class is intented to provide callback behaviour to handle
# an installment successfully being processed
module SolidusSubscriptions
  class SuccessDispatcher < Dispatcher
    def dispatch
      installments.each(&:success!)
      super
    end

    private

    def message
      "Successfully processed installments: #{installments.map(&:id).join(', ')}"
    end
  end
end
