# frozen_string_literal: true

module SolidusSubscriptions
  module ChurnBuster
    class SubscriptionPaymentMethodSerializer < Serializer
      def to_h
        {
          payment_method: {
            source: 'in_house',
            source_id: [
              object.payment_method_to_use&.id,
              object.payment_source_to_use&.id
            ].compact.join('-'),
            type: 'card',
            properties: payment_source_properties,
          },
          customer: SubscriptionCustomerSerializer.serialize(object),
        }
      end

      private

      def payment_source_properties
        if object.payment_source.is_a?(::Spree::CreditCard)
          {
            brand: object.payment_source.cc_type,
            last4: object.payment_source.last_digits,
            exp_month: object.payment_source.month,
            exp_year: object.payment_source.year,
          }
        else
          {}
        end
      end
    end
  end
end
