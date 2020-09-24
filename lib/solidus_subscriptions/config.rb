module SolidusSubscriptions
  module Config
    class << self
      attr_writer :success_dispatcher_class
      def success_dispatcher_class
        @success_dispatcher_class ||= ::SolidusSubscriptions::SuccessDispatcher
      end

      attr_writer :failure_dispatcher_class
      def failure_dispatcher_class
        @failure_dispatcher_class ||= ::SolidusSubscriptions::FailureDispatcher
      end

      attr_writer :payment_failed_dispatcher_class
      def payment_failed_dispatcher_class
        @payment_failed_dispatcher_class ||= ::SolidusSubscriptions::PaymentFailedDispatcher
      end

      attr_writer :out_of_stock_dispatcher
      def out_of_stock_dispatcher_class
        @out_of_stock_dispatcher_class ||= ::SolidusSubscriptions::OutOfStockDispatcher
      end
    end

    mattr_accessor(:maximum_successive_skips) { 1 }

    mattr_accessor(:maximum_total_skips) { nil }

    mattr_accessor(:reprocessing_interval) { 1.day }

    mattr_accessor(:minimum_cancellation_notice) { 1.day }

    mattr_accessor(:processing_queue) { :default }

    mattr_accessor(:subscription_line_item_attributes) do
      [
        :quantity,
        :subscribable_id,
        :interval_length,
        :interval_units,
        :end_date,
      ]
    end

    mattr_accessor(:subscription_attributes) do
      [
        :interval_length,
        :interval_units,
        :end_date,
        :actionable_date,
        shipping_address_attributes: Spree::PermittedAttributes.address_attributes,
        billing_address_attributes: Spree::PermittedAttributes.address_attributes,
      ]
    end
  end
end
