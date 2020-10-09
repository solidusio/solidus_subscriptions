# frozen_string_literal: true

require 'solidus_core'
require 'solidus_support'

require 'deface'
require 'state_machines'

require 'solidus_subscriptions/configuration'
require 'solidus_subscriptions/permission_sets/default_customer'
require 'solidus_subscriptions/permission_sets/subscription_management'
require 'solidus_subscriptions/version'
require 'solidus_subscriptions/engine'

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
