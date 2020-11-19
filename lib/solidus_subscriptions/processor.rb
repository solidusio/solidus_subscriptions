# frozen_string_literal: true

module SolidusSubscriptions
  class Processor
    class << self
      def run
        SolidusSubscriptions::Subscription.actionable.find_each(&method(:process_subscription))
        SolidusSubscriptions::Installment.actionable.with_active_subscription.find_each(&method(:process_installment))
      end

      private

      def process_subscription(subscription)
        ActiveRecord::Base.transaction do
          subscription.successive_skip_count = 0
          subscription.advance_actionable_date

          subscription.cancel! if subscription.pending_cancellation?
          subscription.deactivate! if subscription.can_be_deactivated?

          if SolidusSubscriptions.configuration.clear_past_installments
            subscription.installments.unfulfilled.actionable.each do |installment|
              installment.update!(actionable_date: nil)
            end
          end

          subscription.installments.create!(actionable_date: Time.zone.now)
        end
      end

      def process_installment(installment)
        ProcessInstallmentsJob.perform_later(installment)
      end
    end
  end
end
