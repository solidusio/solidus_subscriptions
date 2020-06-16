module SolidusSubscriptions
  class Dispatcher
    attr_reader :installments, :order

    # Get a new instance of the FailureDispatcher
    #
    # @param installments [Array<SolidusSubscriptions::Installment>] The
    #   installments which have failed to be fulfilled
    #
    # @return [SolidusSubscriptions::FailureDispatcher]
    def initialize(installments, order = nil)
      @installments = installments
      @order = order
    end

    def dispatch
      notify
    end

    private

    def notify
      Rails.logger.tagged('Event') do
        Rails.logger.info message.squish.tr("\n", ' ')
      end
    end

    def message
      raise 'A message should be set in subclasses of Dispatcher'
    end
  end
end
