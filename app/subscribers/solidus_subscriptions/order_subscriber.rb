# frozen_string_literal: true

module SolidusSubscriptions
  class OrderSubscriber
    include Omnes::Subscriber

    handle :order_finalized, with: :create_subscription

    def create_subscription(event)
      SolidusSubscriptions::CreateSubscriptionJob.perform_later(event.payload[:order])
    end
  end
end
