# frozen_string_literal: true

module SolidusSubscriptions
  class ProcessInstallmentJob < ApplicationJob
    queue_as SolidusSubscriptions.configuration.processing_queue

    def perform(installment)
      Checkout.new([installment]).process
    end
  end
end
