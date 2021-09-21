# frozen_string_literal: true

module SolidusSubscriptions
  class Scheduler
    def call
      SolidusSubscriptions::Subscription
        .where(installments: SolidusSubscriptions::Installment.actionable)
        .or(SolidusSubscriptions::Subscription.actionable)
        .distinct
        .find_each do |subscription|
        ProcessSubscriptionJob.perform_later(subscription)
      end
    end
  end
end
