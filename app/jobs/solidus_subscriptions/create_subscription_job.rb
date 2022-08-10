# frozen_string_literal: true

module SolidusSubscriptions
  class CreateSubscriptionJob < ApplicationJob
    queue_as { SolidusSubscriptions.configuration.processing_queue }

    def perform(order)
      SolidusSubscriptions.configuration.subscription_generator_class.call(order)
    end
  end
end
