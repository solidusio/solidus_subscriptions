# frozen_string_literal: true

module SolidusSubscriptions
  module Tracking
    module Event
      class CancelledSubscription < SolidusTracking::Event::Base
        def name
          'Cancelled Subscription'
        end

        def email
          subscription.user.email
        end

        def customer_properties
          SolidusTracking::Serializer::CustomerProperties.serialize(subscription.user)
        end

        def properties
          SolidusSubscriptions::Tracking::Serializer::Subscription
            .serialize(subscription)
            .merge('$event_id' => "#{subscription.id}-#{subscription.updated_at.to_i}")
        end

        def time
          subscription.updated_at
        end

        private

        def subscription
          payload.fetch(:subscription)
        end
      end
    end
  end
end
