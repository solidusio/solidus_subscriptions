# frozen_string_literal: true

module SolidusSubscriptions
  class ProcessSubscriptionJob < ApplicationJob
    queue_as { SolidusSubscriptions.configuration.processing_queue }

    def perform(subscription)
      SolidusSubscriptions.configuration.processor_class.new.call(subscription)
    end
  end
end
