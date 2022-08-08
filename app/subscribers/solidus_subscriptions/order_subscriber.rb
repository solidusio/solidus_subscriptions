# frozen_string_literal: true

module SolidusSubscriptions
  module OrderSubscriber
    include ::Spree::Event::Subscriber
    include ::SolidusSupport::LegacyEventCompat::Subscriber

    event_action :create_subscription, event_name: 'order_finalized'

    private

    def create_subscription(event)
      SolidusSubscriptions::CreateSubscriptionJob.perform_later(event.payload[:order])
    end
  end
end
