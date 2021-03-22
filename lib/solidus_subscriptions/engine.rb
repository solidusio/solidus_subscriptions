# frozen_string_literal: true

require 'spree/core'

require 'solidus_subscriptions'
require 'solidus_subscriptions/permitted_attributes'
require 'solidus_subscriptions/configuration'
require 'solidus_subscriptions/processor'

module SolidusSubscriptions
  class Engine < Rails::Engine
    include SolidusSupport::EngineExtensions

    isolate_namespace SolidusSubscriptions

    engine_name 'solidus_subscriptions'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'solidus_subscriptions.update_permitted_attributes' do
      ::Spree::PermittedAttributes.line_item_attributes << {
        subscription_line_items_attributes: PermittedAttributes.subscription_line_item_attributes | [:id],
      }

      ::Spree::PermittedAttributes.user_attributes << {
        subscriptions_attributes: PermittedAttributes.subscription_attributes | [:id],
      }
    end

    initializer 'solidus_subscriptions.register_promotion_rules', after: 'spree.promo.register.promotion.rules' do |app|
      app.config.spree.promotions.rules << 'SolidusSubscriptions::Promotion::Rules::SubscriptionCreationOrder'
      app.config.spree.promotions.rules << 'SolidusSubscriptions::Promotion::Rules::SubscriptionInstallmentOrder'
    end

    initializer 'solidus_subscriptions.configure_backend' do
      next unless ::Spree::Backend::Config.respond_to?(:menu_items)

      ::Spree::Backend::Config.configure do |config|
        config.menu_items << config.class::MenuItem.new(
          [:subscriptions],
          'repeat',
          url: :admin_subscriptions_path,
          condition: ->{ can?(:admin, SolidusSubscriptions::Subscription) },
          match_path: '/subscriptions'
        )
      end
    end
  end

  def self.table_name_prefix
    'solidus_subscriptions_'
  end
end
