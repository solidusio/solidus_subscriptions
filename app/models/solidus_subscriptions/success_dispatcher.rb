# This service class is intented to provide callback behaviour to handle
# an installment successfully being processed
module SolidusSubscriptions
  class SuccessDispatcher
    attr_reader :installments

    # Get a new instance of a SuccessDispatcher
    #
    # @param [Array<SolidusSubscriptions::Installment>] installments that
    #   were successfully processed
    #
    # @return [SolidusSubscriptions::SuccessDispatcher]
    def initialize(installments)
      @installments = installments
    end

    # Perform successfull installment processing callbacks
    def dispatch
      installments.each(&:success!)
      notify
    end

    private

    def notify
      # Tell someone the installment was sucessfully processed
    end
  end
end
