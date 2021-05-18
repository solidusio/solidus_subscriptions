module SolidusSubscriptions
  class SubscriptionReminderPolicy
    def initialize(subscription)
      @subscription = subscription
    end

    def send_reminder?
      days_for_reminder = SolidusSubscriptions.configuration.days_for_subscription_reminder

      return false if days_for_reminder.to_i <= 0

      @subscription.actionable_date == Time.zone.today + days_for_reminder
    end

    private

    attr_reader :subscription
  end
end
