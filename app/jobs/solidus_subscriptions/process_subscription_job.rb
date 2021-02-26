# frozen_string_literal: true

module SolidusSubscriptions
  class ProcessSubscriptionJob < ApplicationJob
    queue_as { SolidusSubscriptions.configuration.processing_queue }

    def perform(subscription)
      ActiveRecord::Base.transaction do
        if SolidusSubscriptions.configuration.clear_past_installments
          subscription.installments.unfulfilled.actionable.each do |installment|
            installment.update!(actionable_date: nil)
          end
        end

        if subscription.actionable?
          subscription.successive_skip_count = 0
          subscription.advance_actionable_date

          subscription.installments.create!(actionable_date: Time.zone.now)
        end

        subscription.cancel! if subscription.pending_cancellation?
        subscription.deactivate! if subscription.can_be_deactivated?

        subscription.installments.actionable.find_each do |installment|
          SolidusSubscriptions::ProcessInstallmentJob.perform_later(installment)
        end
      end
    end
  end
end
