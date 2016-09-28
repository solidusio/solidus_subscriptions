# This job is responsible for creating a consolidated installment from a
# list of installments and processing it.

module SolidusSubscriptions
  class ProcessInstallmentsJob < ActiveJob::Base
     queue_as Config.processing_queue

     # Process a collection of installments
     #
     # @param [Array<SolidusSubscriptions::Installment>] :installments, The
     #   installments to be processed together and fulfilled by the same order
     #
     # @return [Spree::Order] The order which fulfills the list of installments
     def perform(installments)
       return if installments.empty?
       ConsolidatedInstallment.new(installments).process
     end
  end
end
