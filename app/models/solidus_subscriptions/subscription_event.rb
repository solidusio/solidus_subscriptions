module SolidusSubscriptions
  class SubscriptionEvent < ApplicationRecord
    belongs_to :subscription, class_name: 'SolidusSubscriptions::Subscription', inverse_of: :events

    after_initialize do
      self.details ||= {}
    end

    after_create :emit_event

    private

    def emit_event
      return unless defined?(::Spree::Event)

      ::Spree::Event.fire(
        "solidus_subscriptions.#{event_type}",
        details.deep_symbolize_keys.merge(subscription: subscription),
      )
    end
  end
end
