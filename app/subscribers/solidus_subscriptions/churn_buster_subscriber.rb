# frozen_string_literal: true

module SolidusSubscriptions
  class ChurnBusterSubscriber
    include Omnes::Subscriber

    handle :"solidus_subscriptions.subscription_canceled", with: :report_subscription_cancellation
    handle :"solidus_subscriptions.subscription_ended", with: :report_subscription_ending
    handle :"solidus_subscriptions.installment_succeeded", with: :report_payment_success
    handle :"solidus_subscriptions.installment_failed_payment", with: :report_payment_failure
    handle :"solidus_subscriptions.subscription_payment_method_changed", with: :report_payment_method_change

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
