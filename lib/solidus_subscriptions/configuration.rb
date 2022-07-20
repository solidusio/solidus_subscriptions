# frozen_string_literal: true

module SolidusSubscriptions
  class Configuration
    attr_accessor(
      :churn_buster_account_id,
      :churn_buster_api_key,
      :clear_past_installments,
      :maximum_reprocessing_time,
      :maximum_total_skips,
    )

    attr_writer(
      :failure_dispatcher_class,
      :maximum_successive_skips,
      :minimum_cancellation_notice,
      :order_creator_class,
      :out_of_stock_dispatcher,
      :payment_failed_dispatcher_class,
      :processing_error_handler,
      :processing_queue,
      :reprocessing_interval,
      :subscribable_class,
      :subscription_attributes,
      :subscription_generator_class,
      :subscription_line_item_attributes,
      :success_dispatcher_class,
    )

    def subscription_generator_class
      @subscription_generator_class ||= 'SolidusSubscriptions::SubscriptionGenerator'
      @subscription_generator_class.constantize
    end

    def success_dispatcher_class
      @success_dispatcher_class ||= 'SolidusSubscriptions::Dispatcher::SuccessDispatcher'
      @success_dispatcher_class.constantize
    end

    def failure_dispatcher_class
      @failure_dispatcher_class ||= 'SolidusSubscriptions::Dispatcher::FailureDispatcher'
      @failure_dispatcher_class.constantize
    end

    def payment_failed_dispatcher_class
      @payment_failed_dispatcher_class ||= 'SolidusSubscriptions::Dispatcher::PaymentFailedDispatcher'
      @payment_failed_dispatcher_class.constantize
    end

    def out_of_stock_dispatcher_class
      @out_of_stock_dispatcher_class ||= 'SolidusSubscriptions::Dispatcher::OutOfStockDispatcher'
      @out_of_stock_dispatcher_class.constantize
    end

    def processing_error_handler
      @processing_error_handler ||= 'SolidusSubscriptions::ProcessingErrorHandlers::RailsLogger'
      @processing_error_handler.constantize
    end

    def maximum_successive_skips
      @maximum_successive_skips ||= 1
    end

    def reprocessing_interval
      @reprocessing_interval ||= 1.day
    end

    def minimum_cancellation_notice
      @minimum_cancellation_notice ||= 0.days
    end

    def processing_queue
      @processing_queue ||= :default
    end

    def subscription_line_item_attributes
      @subscription_line_item_attributes ||= [
        :id,
        :quantity,
        :subscribable_id,
        :interval_length,
        :interval_units,
        :end_date
      ]
    end

    def subscription_attributes
      @subscription_attributes ||= [
        :interval_length,
        :interval_units,
        :end_date,
        {
          shipping_address_attributes: Spree::PermittedAttributes.address_attributes,
          billing_address_attributes: Spree::PermittedAttributes.address_attributes
        }
      ]
    end

    def subscribable_class
      @subscribable_class ||= 'Spree::Variant'
      @subscribable_class.constantize
    end

    def churn_buster?
      churn_buster_account_id.present? && churn_buster_api_key.present?
    end

    def order_creator_class
      @order_creator_class ||= 'SolidusSubscriptions::OrderCreator'
      @order_creator_class.constantize
    end
  end
end
