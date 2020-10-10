# frozen_string_literal: true

module SolidusSubscriptions
  module ChurnBuster
    class OrderSerializer < Serializer
      def to_h
        {
          payment: {
            source: 'in_house',
            source_id: object.number,
            amount_in_cents: object.display_total.cents,
            currency: object.currency,
          },
          customer: SubscriptionCustomerSerializer.serialize(object.subscription),
        }
      end
    end
  end
end
