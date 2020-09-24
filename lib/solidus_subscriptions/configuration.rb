module SolidusSubscriptions
  class Configuration
    attr_writer :success_dispatcher_class
    def success_dispatcher_class
      @success_dispatcher_class ||= 'SolidusSubscriptions::SuccessDispatcher'
      @success_dispatcher_class.constantize
    end

    attr_writer :failure_dispatcher_class
    def failure_dispatcher_class
      @failure_dispatcher_class ||= 'SolidusSubscriptions::FailureDispatcher'
      @failure_dispatcher_class.constantize
    end

    attr_writer :payment_failed_dispatcher_class
    def payment_failed_dispatcher_class
      @payment_failed_dispatcher_class ||= 'SolidusSubscriptions::PaymentFailedDispatcher'
      @payment_failed_dispatcher_class.constantize
    end

    attr_writer :out_of_stock_dispatcher
    def out_of_stock_dispatcher_class
      @out_of_stock_dispatcher_class ||= 'SolidusSubscriptions::OutOfStockDispatcher'
      @out_of_stock_dispatcher_class.constantize
    end

    attr_writer :maximum_successive_skips
    def maximum_successive_skips
      @maximum_successive_skips ||= 1
    end

    attr_accessor :maximum_total_skips

    attr_writer :reprocessing_interval
    def reprocessing_interval
      @reprocessing_interval ||= 1.day
    end

    attr_writer :minimum_cancellation_notice
    def minimum_cancellation_notice
      @minimum_cancellation_notice ||= 1.day
    end

    attr_writer :processing_queue
    def processing_queue
      @processing_queue ||= :default
    end

    attr_writer :subscription_line_item_attributes
    def subscription_line_item_attributes
      @subscription_line_item_attributes ||= [
        :quantity,
        :subscribable_id,
        :interval_length,
        :interval_units,
        :end_date,
      ]
    end

    attr_writer :subscription_attributes
    def subscription_attributes
      @subscription_attributes ||= [
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
