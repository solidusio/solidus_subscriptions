# frozen_string_literal: true

module SolidusSubscriptions
  module Tracking
    module Serializer
      class Subscription < SolidusTracking::Serializer::Base
        def subscription
          object
        end

        def as_json(_options = {})
          {
            'Id' => subscription.id,
            'ActionableDate' => subscription.actionable_date&.to_s,
            'State' => subscription.state,
            'SkipCount' => subscription.skip_count,
            'SuccessiveSkipCount' => subscription.successive_skip_count,
            'ShippingAddress' => SolidusTracking::Serializer::Address.serialize(subscription.shipping_address_to_use),
            'BillingAddress' => SolidusTracking::Serializer::Address.serialize(subscription.billing_address_to_use),
            'IntervalLength' => subscription.interval_length,
            'IntervalUnits' => subscription.interval_units,
            'EndDate' => subscription.end_date&.to_date&.to_s,
            'PaymentSource' => SolidusTracking::Serializer::PaymentSource.serialize(subscription.payment_source),
            'Items' => subscription.line_items.map(&SolidusSubscriptions::Tracking::Serializer::SubscriptionLineItem.method(:serialize)),
          }
        end
      end
    end
  end
end
