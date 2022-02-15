# frozen_string_literal: true

require 'spree/core'

require 'solidus_subscriptions'
require 'solidus_subscriptions/permitted_attributes'
require 'solidus_subscriptions/config'
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

    initializer 'register_subscription_promotion_rule', after: 'spree.promo.register.promotion.rules' do |app|
      app.config.spree.promotions.rules << 'SolidusSubscriptions::SubscriptionPromotionRule'
      app.config.spree.promotions.rules << 'SolidusSubscriptions::SubscriptionOrderPromotionRule'
      app.config.spree.promotions.rules << 'SolidusSubscriptions::DisableSubscriptionOrderPromotionRule'
    end

    initializer 'solidus_subscriptions.add_admin_section' do
      Spree::Backend::Config.configure do |config|
        config.menu_items << config.class::MenuItem.new(
          [:subscriptions],
          'repeat',
          url: :admin_subscriptions_path,
          condition: ->{ can?(:admin, SolidusSubscriptions::Subscription) }
        )
      end
    end

    config.after_initialize do
      PermittedAttributes.update_spree_permiteed_attributes
      ::Spree::Ability.register_ability(SolidusSubscriptions::Ability)
    end
  end

  def self.table_name_prefix
    'solidus_subscriptions_'
  end
end
