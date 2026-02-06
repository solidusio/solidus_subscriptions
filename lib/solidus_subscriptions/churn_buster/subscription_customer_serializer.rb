# frozen_string_literal: true

module SolidusSubscriptions
  module ChurnBuster
    class SubscriptionCustomerSerializer < Serializer
      def to_h
        {
          source: "in_house",
          source_id: object.id,
          email: object.user.email,
          properties: {
            name: name
          }
        }
      end

      private

      def name
        object.shipping_address_to_use.name
      end
    end
  end
end
