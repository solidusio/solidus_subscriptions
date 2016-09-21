module SolidusSubscriptions
  module Config
    class << self
      # Time between an installment failing to be processed and the system
      # retrying to fulfil it
      mattr_accessor(:reprocessing_interval) { 1.day }

      # SolidusSubscriptions::LineItem attributes which are allowed to
      # be updated from user data
      #
      # This is useful in the case where certain fields should not be allowed to
      # be modified by the user. This locks these attributes from being passed
      # in to the orders controller (or the api controller).

      # Ie. if a store does not want to allow users to configure the number of
      # installments they will receive. Add this to an initializer:

      # ```
      # SolidusSubscriptions::Config.subscription_line_item_attributes = [
      #   :quantity,
      #   :interval,
      #   :subscribable_id
      # ]
      # ```

      # This configuration also easily allows the gem to be customized to track
      # more information on the subcriptions line items.
      mattr_accessor(:subscription_line_item_attributes) do
        [
          :quantity,
          :subscribable_id,
          :interval,
          :max_installments
        ]
      end

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
