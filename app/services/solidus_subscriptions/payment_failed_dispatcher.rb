# This service class is intended to provide callback behaviour to handle
# the case where a subscription order cannot be processed because a payment
# failed
module SolidusSubscriptions
  class PaymentFailedDispatcher < Dispatcher
    def dispatch
      order.touch :completed_at
      order.cancel!

      installments.each { |i| i.payment_failed!(order) }
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
