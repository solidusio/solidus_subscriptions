# frozen_string_literal: true

module SolidusSubscriptions
  class ScheduleSubscriptionProcessingJob < ApplicationJob
    queue_as { SolidusSubscriptions.configuration.processing_queue }

    def perform
      SolidusSubscriptions::Scheduler.new.call
    end
  end
end
