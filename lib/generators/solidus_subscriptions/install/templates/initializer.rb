# frozen_string_literal: true

SolidusSubscriptions.configure do |config|
  # ========================================= Basic config =========================================

  # The ActiveRecord model users can subscribe to.
  # config.subscribable_class = 'Spree::Variant'

  # Which queue is responsible for processing subscription background jobs.
  # config.processing_queue = :default

  # Maximum number of times a user can skip their subscription before it must be processed.
  # config.maximum_successive_skips = 1

  # Maximum number of times a user can skip their subscription.
  # config.maximum_total_skips = nil

  # Minimum days between the current date and the next installment for the installment not to be
  # processed after the user cancels their subscription.
  # config.minimum_cancellation_notice = 1.day

  # Time between an installment failing to be processed and the system retrying to fulfill it.
  # config.reprocessing_interval = 1.day

  # Maximum number of times the system attempts to reprocess a failed payment before cancelling
  # the subscription (`nil` is the default and will make the system reprocess indefinitely).
  # config.maximum_reprocessing_attempts = nil

  # Disables the Subscriptions link on the admin menu (it is enabled by default)
  # config.disable_admin_menu_link = true

  # ========================================= Dispatchers ==========================================
  #
  # These dispatchers are pluggable. If you override any handlers, it is highly encouraged that you
  # subclass from the the dispatcher you are replacing and call `super` from within `#dispatch`.

  # This handler is called when a subscription order is successfully placed.
  # config.success_dispatcher_class = 'SolidusSubscriptions::SuccessDispatcher'

  # This handler is called when a group of installments fails to be processed.
  # config.failure_dispatcher_class = 'SolidusSubscriptions::FailureDispatcher'

  # This handler is called when a payment fails on a subscription order.
  # config.payment_failed_dispatcher_class = 'SolidusSubscriptions::PaymentFailedDispatcher'

  # This handler is called when there isn't enough stock to fulfill an installment.
  # config.out_of_stock_dispatcher = 'SolidusSubscriptions::OutOfStockDispatcher'

  # ===================================== Permitted attributes =====================================
  #
  # In this section, you can override the list of attributes the user can pass to the controllers.
  #
  # This is useful in the case where certain fields should not be allowed to be modified by the
  # user, or if you add additional fields to the extension's model and you want the users to be able
  # to set them.

  # Attributes the user can specify for subscriptions.
  # config.subscription_attributes = [
  #   :interval_length,
  #   :interval_units,
  #   :end_date,
  #   shipping_address_attributes: Spree::PermittedAttributes.address_attributes,
  #   billing_address_attributes: Spree::PermittedAttributes.address_attributes,
  # ]

  # Attributes the user be specify for subscription line items.
  # config.subscription_line_item_attributes = [
  #   :quantity,
  #   :subscribable_id,
  #   :interval_length,
  #   :interval_units,
  #   :end_date,
  # ]

  # ========================================= Churn Buster =========================================
  #
  # This extension can integrate with Churn Buster for churn mitigation and failed payment recovery.
  # If you want to integrate with Churn Buster, simply configure your credentials below.
  #
  # NOTE: If you integrate with Churn Buster and override any of the handlers, make sure to call
  # `super` or copy-paste the original integration code or things won't work!

  # Your Churn Buster account ID.
  # config.churn_buster_account_id = 'YOUR_CHURN_BUSTER_ACCOUNT_ID'

  # Your Churn Buster API key.
  # config.churn_buster_api_key = 'YOUR_CHURN_BUSTER_API_KEY'
end
