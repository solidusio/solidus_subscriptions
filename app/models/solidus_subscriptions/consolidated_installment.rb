# This class takes a collection of installments and populates a new spree
# order with the correct contents based on the subscriptions associated to the
# intallments. This is to group together subscriptions being
# processed on the same day for a specific user
module SolidusSubscriptions
  class ConsolidatedInstallment
    # @return [Array<Installment>] The collection of installments to be used
    #   when generating a new order
    attr_reader :installments

    # Get a new instance of a ConsolidatedInstallment
    #
    # @param [Array<Installment>] :installments, The collection of installments
    # to be used when generating a new order
    def initialize(installments)
      @installments = installments
    end

    # Generate a new Spree::Order based on the information associated to the
    # installments
    #
    # @return [Spree::Order]
    def process
      Spree::Order.new
    end
  end
end
