# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

require 'deface'
require 'httparty'
require 'state_machines'

require 'solidus_subscriptions/configuration'
require 'solidus_subscriptions/permission_sets/default_customer'
require 'solidus_subscriptions/permission_sets/subscription_management'
require 'solidus_subscriptions/version'
require 'solidus_subscriptions/engine'
require 'solidus_subscriptions/checkout'
require 'solidus_subscriptions/subscription_generator'
require 'solidus_subscriptions/subscription_line_item_builder'
require 'solidus_subscriptions/dispatcher/base'
require 'solidus_subscriptions/dispatcher/failure_dispatcher'
require 'solidus_subscriptions/dispatcher/out_of_stock_dispatcher'
require 'solidus_subscriptions/dispatcher/payment_failed_dispatcher'
require 'solidus_subscriptions/dispatcher/success_dispatcher'
require 'solidus_subscriptions/order_creator'

module SolidusSubscriptions
  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end
  end
end
