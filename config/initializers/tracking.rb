# frozen_string_literal: true

if defined?(SolidusTracking)
  require 'solidus_subscriptions/tracking/event/created_subscription'
  require 'solidus_subscriptions/tracking/event/cancelled_subscription'
  require 'solidus_subscriptions/tracking/event/skipped_subscription'
  require 'solidus_subscriptions/tracking/serializer/subscription'
  require 'solidus_subscriptions/tracking/serializer/subscription_line_item'

  SolidusTracking.configure do |config|
    config.events['solidus_subscriptions.created_subscription'] = SolidusSubscriptions::Tracking::Event::CreatedSubscription
    config.events['solidus_subscriptions.canceled_subscription'] = SolidusSubscriptions::Tracking::Event::CancelledSubscription
    config.events['solidus_subscriptions.skipped_subscription'] = SolidusSubscriptions::Tracking::Event::SkippedSubscription
  end

  Spree.config do |config|
    config.events.subscribers << 'SolidusSubscriptions::TrackingSubscriber'
  end
end
