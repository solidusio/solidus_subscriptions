# frozen_string_literal: true

module SolidusSubscriptions
  module TrackingSubscriber
    include ::Spree::Event::Subscriber

    event_action(
      :track_subscription_creation,
      event_name: 'solidus_subscriptions.subscription_created',
    )

    event_action(
      :track_subscription_cancellation,
      event_name: 'solidus_subscriptions.subscription_canceled',
    )

    event_action(
      :track_subscription_skip,
      event_name: 'solidus_subscriptions.subscription_skipped',
    )

    def track_subscription_creation(event)
      SolidusTracking.track_later(
        'solidus_subscriptions.created_subscription',
        subscription: event.payload[:subscription],
      )
    end

    def track_subscription_cancellation(event)
      SolidusTracking.track_later(
        'solidus_subscriptions.canceled_subscription',
        subscription: event.payload[:subscription],
      )
    end

    def track_subscription_skip(event)
      SolidusTracking.track_later(
        'solidus_subscriptions.skipped_subscription',
        subscription: event.payload[:subscription],
      )
    end
  end
end
