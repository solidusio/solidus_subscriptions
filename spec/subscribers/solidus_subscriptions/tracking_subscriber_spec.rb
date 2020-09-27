# frozen_string_literal: true

RSpec.describe SolidusSubscriptions::TrackingSubscriber do
  describe '.track_subscription_creation' do
    it 'tracks the event via solidus_tracking' do
      subscription = create(:subscription)

      expect(SolidusTracking::TrackEventJob).to have_been_enqueued.with(
        'solidus_subscriptions.created_subscription',
        subscription: subscription,
      )
    end
  end

  describe '.track_subscription_cancellation' do
    it 'tracks the event via solidus_tracking' do
      subscription = create(:subscription)

      Spree::Event.fire(
        'solidus_subscriptions.subscription_canceled',
        subscription: subscription,
      )

      expect(SolidusTracking::TrackEventJob).to have_been_enqueued.with(
        'solidus_subscriptions.canceled_subscription',
        subscription: subscription,
      )
    end
  end

  describe '.track_subscription_skip' do
    it 'tracks the event via solidus_tracking' do
      subscription = create(:subscription)

      Spree::Event.fire(
        'solidus_subscriptions.subscription_skipped',
        subscription: subscription,
      )

      expect(SolidusTracking::TrackEventJob).to have_been_enqueued.with(
        'solidus_subscriptions.skipped_subscription',
        subscription: subscription,
      )
    end
  end
end
