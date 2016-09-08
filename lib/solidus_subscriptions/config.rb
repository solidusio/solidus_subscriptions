module SolidusSubscriptions
  module Config
    class << self
      def default_gateway=(gateway)
        @gateway = gateway
      end

      def default_gateway
        @gateway ||= Spree::Gateway.where(active: true).detect do |gateway|
          gateway.payment_source_class == Spree::CreditCard
        end

        return @gateway if @gateway

        raise <<-MSG.strip
          SolidusSubscriptions requires a Credit Card Gateway

          Make sure at lease one Spree::PaymentMethod exists with a
          #payment_source_class of Spree::CreditCard.

          Alternatively, you can manually set the Gateway you would like to use by
          adding the following to an initializer:

          SolidusSubscription::Config.default_gateway = my_gateway
        MSG
      end
    end
  end
end
