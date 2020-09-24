# frozen_string_literal: true

FactoryBot.define do
  factory :subscription_event, class: 'SolidusSubscriptions::SubscriptionEvent' do
    subscription
    event_type { 'test_event' }
  end
end
