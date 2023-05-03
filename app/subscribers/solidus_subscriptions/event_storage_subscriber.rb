# frozen_string_literal: true

module SolidusSubscriptions
  class EventStorageSubscriber
    include Omnes::Subscriber

    handle :"solidus_subscriptions.subscription_created", with: :track_subscription_created
    handle :"solidus_subscriptions.subscription_activated", with: :track_subscription_activated
    handle :"solidus_subscriptions.subscription_canceled", with: :track_subscription_canceled
    handle :"solidus_subscriptions.subscription_ended", with: :track_subscription_ended
    handle :"solidus_subscriptions.subscription_shipping_address_changed", with: :track_subscription_shipping_address_changed
    handle :"solidus_subscriptions.subscription_billing_address_changed", with: :track_subscription_billing_address_changed
    handle :"solidus_subscriptions.subscription_frequency_changed", with: :track_subscription_frequency_changed

    def track_subscription_created(event)
      event.payload.fetch(:subscription).events.create!(
        event_type: 'subscription_created',
        details: event.payload.fetch(:subscription).as_json,
      )
    end

    def track_subscription_activated(event)
      event.payload.fetch(:subscription).events.create!(
        event_type: 'subscription_activated',
        details: event.payload.fetch(:subscription).as_json,
      )
    end

    def track_subscription_canceled(event)
      event.payload.fetch(:subscription).events.create!(
        event_type: 'subscription_canceled',
        details: event.payload.fetch(:subscription).as_json,
      )
    end

    def track_subscription_ended(event)
      event.payload.fetch(:subscription).events.create!(
        event_type: 'subscription_ended',
        details: event.payload.fetch(:subscription).as_json,
      )
    end

    def track_subscription_shipping_address_changed(event)
      event.payload.fetch(:subscription).events.create!(
        event_type: 'subscription_shipping_address_changed',
        details: event.payload.fetch(:subscription).as_json,
      )
    end

    def track_subscription_billing_address_changed(event)
      event.payload.fetch(:subscription).events.create!(
        event_type: 'subscription_billing_address_changed',
        details: event.payload.fetch(:subscription).as_json,
      )
    end

    def track_subscription_frequency_changed(event)
      event.payload.fetch(:subscription).events.create!(
        event_type: 'subscription_frequency_changed',
        details: event.payload.fetch(:subscription).as_json,
      )
    end
  end
end
