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
require 'solidus_subscriptions/churn_buster/client'
require 'solidus_subscriptions/churn_buster/serializer'
require 'solidus_subscriptions/churn_buster/subscription_customer_serializer'
require 'solidus_subscriptions/churn_buster/subscription_payment_method_serializer'
require 'solidus_subscriptions/churn_buster/subscription_serializer'
require 'solidus_subscriptions/churn_buster/order_serializer'
require 'solidus_subscriptions/checkout'
require 'solidus_subscriptions/subscription_generator'
require 'solidus_subscriptions/subscription_line_item_builder'
require 'solidus_subscriptions/dispatcher/base'
require 'solidus_subscriptions/dispatcher/failure_dispatcher'
require 'solidus_subscriptions/dispatcher/out_of_stock_dispatcher'
require 'solidus_subscriptions/dispatcher/payment_failed_dispatcher'
require 'solidus_subscriptions/dispatcher/success_dispatcher'

module SolidusSubscriptions
  class << self
    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def churn_buster
      return unless configuration.churn_buster?

      @churn_buster ||= ChurnBuster::Client.new(
        account_id: SolidusSubscriptions.configuration.churn_buster_account_id,
        api_key: SolidusSubscriptions.configuration.churn_buster_api_key,
      )
    end
  end
end
