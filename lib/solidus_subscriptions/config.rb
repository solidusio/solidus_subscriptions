module SolidusSubscriptions
  module Config
    class << self
      # Processing Event handlers
      # These handlers are pluggable, however it is highly encouraged that you
      # subclass from the the dispatcher you are replacing, and call super
      # from within the #dispatch method (if you override it)
      #
      # This handler is called when a susbcription order is successfully placed.
      attr_writer :success_dispatcher_class

      def success_dispatcher_class
        @success_dispatcher_class ||= ::SolidusSubscriptions::Dispatcher::SuccessDispatcher
      end

      # This handler is called when an order cant be placed for a group of
      # installments
      attr_writer :failure_dispatcher_class

      def failure_dispatcher_class
        @failure_dispatcher_class ||= ::SolidusSubscriptions::Dispatcher::FailureDispatcher
      end

      # This handler is called when a payment fails on a subscription order
      attr_writer :payment_failed_dispatcher_class

      def payment_failed_dispatcher_class
        @payment_failed_dispatcher_class ||= ::SolidusSubscriptions::Dispatcher::PaymentFailedDispatcher
      end

      # This handler is called when installemnts cannot be fulfilled due to lack
      # of stock
      attr_writer :out_of_stock_dispatcher_class

      def out_of_stock_dispatcher_class
        @out_of_stock_dispatcher_class ||= ::SolidusSubscriptions::Dispatcher::OutOfStockDispatcher
      end

      # This handler is called when an unexpected error appeared while finalizing the renewal order.
      attr_writer :admin_dispatcher_class

      def admin_dispatcher_class
        @admin_dispatcher_class ||= ::SolidusSubscriptions::Dispatcher::AdminDispatcher
      end

      # This handler is called when a renewal order is initiated
      attr_writer :order_creator_class

      def order_creator_class
        @order_creator_class ||= ::SolidusSubscriptions::OrderRenewal::OrderCreator
      end

      # The *subscription_email_class* must have the following methods:
      # * cancel_email
      # * restart_email
      #
      # The *subscription_failure_notification_email_class* must have the following methods:
      # * subscription_failure_email
      #
      attr_accessor :subscription_email_class, :subscription_failure_notification_email_class

      def default_gateway(&block)
        return @gateway.call unless block_given?
        @gateway = block
      end
    end

    # Maximum number of times a user can skip their subscription before it
    # must be processed
    mattr_accessor(:maximum_successive_skips) { 1 }

    # Limit on the number of times a user can skip their subscription. Once
    # this limit is reached, no skips are permitted
    mattr_accessor(:maximum_total_skips) { nil }

    # Time between an installment failing to be processed and the system
    # retrying to fulfil it
    mattr_accessor(:reprocessing_interval) { 1.day }

    mattr_accessor(:minimum_cancellation_notice) { 1.day }

    # Limit on the number of times a subscription failure to create an order.
    # Once this limit is reached, the current subscription activation period is skipped,
    # but the subscription stays active.
    mattr_accessor(:maximum_total_failure_skips) { nil }

    # Which queue is responsible for processing subscriptions
    mattr_accessor(:processing_queue) { :default }

    # SolidusSubscriptions::LineItem attributes which are allowed to
    # be updated from user data
    #
    # This is useful in the case where certain fields should not be allowed to
    # be modified by the user. This locks these attributes from being passed
    # in to the orders controller (or the api controller).

    # Ie. if a store does not want to allow users to configure the end date of
    # a subscription. Add this to an initializer:

    # ```
    # SolidusSubscriptions::Config.subscription_line_item_attributes = [
    #   :quantity,
    #   :interval_length,
    #   :interval_units,
    #   :subscribable_id
    # ]
    # ```
    # This configuration also easily allows the gem to be customized to track
    # more information on the subcriptions line items.
    mattr_accessor(:subscription_line_item_attributes) do
      [
        :quantity,
        :subscribable_id,
        :interval_length,
        :interval_units,
        :end_date
      ]
    end

    # SolidusSubscriptions::Subscription attributes which are allowed to
    # be updated from user data
    mattr_accessor(:subscription_attributes) do
      [
        :actionable_date,
        { shipping_address_attributes: Spree::PermittedAttributes.address_attributes }
      ]
    end

    # How many days should user be informed before his subscription creates an order for him?
    # Users will not be informed if this config param set to 0.
    mattr_accessor(:reminder_before_order_in_days) { 0 }

    mattr_accessor(:failed_subscriptions_limit) { 3 }
  end
end
