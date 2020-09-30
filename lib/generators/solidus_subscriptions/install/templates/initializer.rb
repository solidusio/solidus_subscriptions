# frozen_string_literal: true

SolidusSubscriptions.configure do |config|
  # These handlers are pluggable, however it is highly encouraged that
  # you subclass from the the dispatcher you are replacing, and call
  # `super` from within the #dispatch method (if you override it).

  # The ActiveRecord model users can subscribe to.
  # config.subscribable_class = 'Spree::Variant'

  # This handler is called when a subscription order is successfully placed.
  # config.success_dispatcher_class = 'SolidusSubscriptions::SuccessDispatcher'

  # This handler is called when a group of installments fails to be processed.
  # config.failure_dispatcher_class = 'SolidusSubscriptions::FailureDispatcher'

  # This handler is called when a payment fails on a subscription order.
  # config.payment_failed_dispatcher_class = 'SolidusSubscriptions::PaymentFailedDispatcher'

  # This handler is called when there isn't enough stock to fulfill an installment.
  # config.out_of_stock_dispatcher = 'SolidusSubscriptions::OutOfStockDispatcher'

  # Maximum number of times a user can skip their subscription before it
  # must be processed.
  # config.maximum_successive_skips = 1

  # Maximum number of times a user can skip their subscription. Once this limit
  # is reached, no more skips are permitted.
  # config.maximum_total_skips = nil

  # Minimum days between the current date and the next installment for the
  # installment not to be processed after subscription cancellation.
  # config.minimum_cancellation_notice = 1.day

  # Time between an installment failing to be processed and the system
  # retrying to fulfill it.
  # config.reprocessing_interval = 1.day

  # Which queue is responsible for processing subscription background jobs.
  # config.processing_queue = :default

  # SolidusSubscriptions::LineItem attributes which are allowed to
  # be updated from user data
  #
  # This is useful in the case where certain fields should not be allowed to
  # be modified by the user. This locks these attributes from being passed
  # to the orders controller (or the API controller).
  #
  # For example, if a store does not want to allow users to configure the end
  # date of a subscription, set this:
  #
  # ```
  # SolidusSubscriptions.configuration.subscription_line_item_attributes = [
  #   :quantity,
  #   :subscribable_id,
  #   :interval_length,
  #   :interval_units,
  # ]
  # ```
  #
  # You can also add additional attributes that you want to track in the
  # subscription line items.
  # config.subscription_line_item_attributes = [
  #   :quantity,
  #   :subscribable_id,
  #   :interval_length,
  #   :interval_units,
  #   :end_date,
  # ]

  # SolidusSubscriptions::Subscription attributes which are allowed to
  # be modified by the user.
  # config.subscription_attributes = [
  #   :interval_length,
  #   :interval_units,
  #   :end_date,
  #   shipping_address_attributes: Spree::PermittedAttributes.address_attributes,
  #   billing_address_attributes: Spree::PermittedAttributes.address_attributes,
  # ]
end
