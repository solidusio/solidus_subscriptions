# Configuration
The following options can be added to a rails initializer to modify the
behaviour of the gem:

```ruby
# config/initializers/subscriptions.rb
# Values set in this example are the defaults

# The gateway the `ConsolidatedInstallment` will use when charging recurring
# orders. We highly recommend setting this to a specific value
SolidusSubscriptions::Config.default_gateway = my_gateway

# Defines how long the system will wait before allowing a failed installment to
# be reprocessed by the `Processor`. Set to nil to stop reprocessing failedx
# installments
SolidusSubscriptions::Config.reprocessing_interval = 1.days

# Maximum number of times a user can skip their subscription before it
# must be processed
mattr_accessor(:maximum_successive_skips) { 1 }

# Limit on the number of times a user can skip thier subscription. Once
# this limit is reached, no skips are permitted
mattr_accessor(:maximum_total_skips) { nil }

# Notice required to cancel a subscription. A cancellation with insufficient
# notice will result in the subscription being moved to the
# `pending_cancellation` state. Subscriptions pending cancellations will be
# processed an additional one (1) time and then marked as cancelled.
SolidusSubscriptions::Config.minimum_cancellation_notice = 1.day

# Which queue is responsible for processing subscriptions
mattr_accessor(:processing_queue) { :default }

# SolidusSubscriptions::LineItem attributes which are allowed to
# be updated from user data
#
# This is useful in the case where certain fields should not be allowed to
# be modified by the user. This locks these attributes from being passed
# in to the orders controller (or the api controller).
SolidusSubscriptions::Config.subscription_line_item_attributes = [
  :quantity,
  :subscribable_id,
  :interval_length,
  :interval_units,
  :end_date
]

# Dispatchers (processing callbacks)

# These handlers are pluggable, however it is highly encouraged that you
# subclass from the the dispatcher you are replacing, and call super
# from within the #dispatch method (if you override it)

# This handler is called when a susbcription order is successfully placed.
SolidusSubscriptions::Config.success_dispatcher_class = ::SolidusSubscriptions::SuccessDispatcher

# This handler is called when an order cant be placed for a group of installments
SolidusSubscriptions::Config.failure_dispatcher_class = ::SolidusSubscriptions::FailureDispatcher

# This handler is called when a payment fails on a subscription order
SolidusSubscriptions::Config.payment_failed_dispatcher_class = ::SolidusSubscriptions::PaymentFailedDispatcher

# This handler is called when installemnts cannot be fulfilled due to lack of stock
SolidusSubscriptions::Config.out_of_stock_dispatcher_class = ::SolidusSubscriptions::OutOfStockDispatcher
