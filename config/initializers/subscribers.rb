# frozen_string_literal: true

Spree.config do |config|
  config.events.subscribers << 'SolidusSubscriptions::EventStorageSubscriber'
end
