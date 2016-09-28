# This service class is intented to provide callback behaviour to handle
# the case where a subscription order cannot be processed because a payment
# failed
module SolidusSubscriptions
  class PaymentFailedDispatcher
    attr_reader :installments

    # Create a new instance of a PaymentFailed dispatcher.
    #
    # @param installments [Array<SolidusSubscriptions::Installment>] The
    #   installment the failed order would have fulfilled, but didnt because
    #   the payment failed
    #
    # @return [SolidusSubscriptions::PaymentFailedDispatcher]
    def initialize(installments)
      @installments = installments
    end

    # Handle a failed payment on a subscription order for multiple installments
    def dispatch
      installments.each(&:payment_failed!)
      log_failure
    end

    private

    def log_failure
      # notify somebody that stuff went wrong
    end
  end
end
