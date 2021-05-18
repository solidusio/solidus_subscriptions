# frozen_string_literal: true

require_relative 'subscription_reminder_policy'

module SolidusSubscriptions
  class Reminder
    class << self
      def run
        SolidusSubscriptions::Subscription
          .where(installments: SolidusSubscriptions::Installment.unfulfilled)
          .or(SolidusSubscriptions::Subscription.where.not(state: ["canceled", "inactive"]))
          .distinct
          .find_each
          .select { |subscription| SubscriptionReminderPolicy.new(subscription).send_reminder? }
          .map do |subscription|
            SolidusSubscriptions::ProcessReminderJob.perform_later(subscription)
          end
      end
    end
  end
end