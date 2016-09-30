module SolidusSubscriptions
  class Dispatcher
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

    def dispatch
      notify
    end

    private

    def notify
      Rails.logger.info message
    end

    def message
      raise 'A message should be set in subclasses of Dispatcher'
    end
  end
end
