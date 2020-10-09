# frozen_string_literal: true

if Spree.solidus_gem_version < Gem::Version.new('2.11.0')
  require SolidusSubscriptions::Engine.root.join('app/subscribers/solidus_subscriptions/event_storage_subscriber')
  require SolidusSubscriptions::Engine.root.join('app/subscribers/solidus_subscriptions/churn_buster_subscriber')

  SolidusSubscriptions::ChurnBusterSubscriber.subscribe!
  SolidusSubscriptions::EventStorageSubscriber.subscribe!
end
