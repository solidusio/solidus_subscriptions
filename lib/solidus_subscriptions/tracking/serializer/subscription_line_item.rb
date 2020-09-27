# frozen_string_literal: true

module SolidusSubscriptions
  module Tracking
    module Serializer
      class SubscriptionLineItem < SolidusTracking::Serializer::Base
        def line_item
          object
        end

        def as_json(_options = {})
          {
            'Id' => line_item.id,
            'Quantity' => line_item.quantity,
            'ProductName' => line_item.subscribable.descriptive_name,
            'ProductURL' => SolidusTracking.configuration.variant_url_builder.call(line_item.subscribable),
            'ImageURL' => SolidusTracking.configuration.image_url_builder.call(line_item.subscribable),
          }
        end
      end
    end
  end
end
