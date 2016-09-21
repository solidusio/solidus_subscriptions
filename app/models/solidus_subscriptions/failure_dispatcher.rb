# A handler for behaviour that should happen after installments are marked as
# failures
module SolidusSubscriptions
  class FailureDispatcher
    attr_reader :installments

    # Get a new instance of the FailureDispatcher
    #
    # @param [Array<SolidusSubscriptions::Installment>] :installments,
    #   the installments which have failed to be fulfilled
    #
    # @return [SolidusSubscriptions::FailureDispatcher]
    def initialize(installments)
      @installments = installments
    end

    # Run after failure callback methods
    def dispatch
      installments.each(&:failed)
      notify
    end

    private

    def notify
      # Tell someone stuff happened
    end
  end
end
