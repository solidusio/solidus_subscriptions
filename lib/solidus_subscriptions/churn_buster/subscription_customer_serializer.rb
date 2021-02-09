# frozen_string_literal: true

module SolidusSubscriptions
  module ChurnBuster
    class SubscriptionCustomerSerializer < Serializer
      def to_h
        {
          source: 'in_house',
          source_id: object.id,
          email: object.user.email,
          properties: {
            name: name
          },
        }
      end

      private

      def name
        if ::Spree.solidus_gem_version < Gem::Version.new('2.11.0')
          "#{object.shipping_address_to_use.first_name} #{object.shipping_address_to_use.last_name}"
        else
          object.shipping_address_to_use.name
        end
      end
    end
  end
end
