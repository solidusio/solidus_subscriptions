# frozen_string_literal: true

module SolidusSubscriptions
  class ProcessInstallmentJob < ApplicationJob
    queue_as { SolidusSubscriptions.configuration.processing_queue }

    def perform(installment)
      Checkout.new(installment).process
    rescue StandardError => e
      SolidusSubscriptions.configuration.processing_error_handler&.call(e)
    end
  end
end
