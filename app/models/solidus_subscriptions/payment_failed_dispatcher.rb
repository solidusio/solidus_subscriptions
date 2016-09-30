# This service class is intented to provide callback behaviour to handle
# the case where a subscription order cannot be processed because a payment
# failed
module SolidusSubscriptions
  class PaymentFailedDispatcher < Dispatcher
    def dispatch
      installments.each(&:payment_failed!)
      super
    end

    private

    def message
      "
      The following installments could not be processed due to payment
      authorization failure: #{installments.map(&:id).join(', ')}
      "
    end
  end
end
