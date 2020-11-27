# frozen_string_literal: true

module SolidusSubscriptions
  module ChurnBusterSubscriber
    include ::Spree::Event::Subscriber

    event_action :report_subscription_cancellation, event_name: 'solidus_subscriptions.subscription_canceled'
    event_action :report_subscription_ending, event_name: 'solidus_subscriptions.subscription_ended'
    event_action :report_payment_success, event_name: 'solidus_subscriptions.installment_succeeded'
    event_action :report_payment_failure, event_name: 'solidus_subscriptions.installment_failed_payment'
    event_action :report_payment_method_change, event_name: 'solidus_subscriptions.subscription_payment_method_changed'

    def report_subscription_cancellation(event)
      churn_buster&.report_subscription_cancellation(event.payload.fetch(:subscription))
    end

    def report_subscription_ending(event)
      churn_buster&.report_subscription_cancellation(event.payload.fetch(:subscription))
    end

    def report_payment_success(event)
      churn_buster&.report_successful_payment(event.payload.fetch(:order))
    end

    def report_payment_failure(event)
      churn_buster&.report_failed_payment(event.payload.fetch(:order))
    end

    def report_payment_method_change(event)
      churn_buster&.report_payment_method_change(event.payload.fetch(:subscription))
    end

    private

    def churn_buster
      SolidusSubscriptions.churn_buster
    end
  end
end
