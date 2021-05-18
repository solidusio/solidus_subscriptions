# frozen_string_literal: true

module SolidusSubscriptions
  class ProcessReminderJob < ApplicationJob
    queue_as { SolidusSubscriptions.configuration.processing_queue }

    def perform(subscription)
      # TODO: fill
    end
  end
end
