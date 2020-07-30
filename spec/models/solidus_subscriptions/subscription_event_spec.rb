require 'spec_helper'

RSpec.describe SolidusSubscriptions::SubscriptionEvent do
  describe '#save' do
    it 'emits a Solidus event' do
      event_klass = class_spy('Spree::Event')
      stub_const('Spree::Event', event_klass)

      subscription = create(:subscription)
      subscription_event = create(:subscription_event, subscription: subscription, event_type: 'test_event', details: { foo: 'bar' })

      expect(event_klass).to have_received(:fire).with('solidus_subscriptions.test_event', subscription: subscription_event.subscription, foo: 'bar')
    end
  end
end
