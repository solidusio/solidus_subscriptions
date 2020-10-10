# frozen_string_literal: true

module SolidusSubscriptions
  module ChurnBuster
    class SubscriptionSerializer < Serializer
      def to_h
        {
          subscription: {
            source: 'in_house',
            source_id: object.id
          },
          customer: SubscriptionCustomerSerializer.serialize(object),
        }
      end
    end
  end
end
