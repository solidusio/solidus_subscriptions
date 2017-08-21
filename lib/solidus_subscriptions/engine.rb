module SolidusSubscriptions
  class Engine < Rails::Engine
    require 'spree/core'
    require 'solidus_subscriptions/permitted_attributes'
    require 'solidus_subscriptions/config'
    require 'solidus_subscriptions/processor'

    isolate_namespace SolidusSubscriptions
    engine_name 'solidus_subscriptions'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    config.autoload_paths << config.root.join('app', 'jobs')

    initializer 'configure spree subcription permitted attributes', after: 'require subscription lib helpers' do
      PermittedAttributes.update_spree_permiteed_attributes
    end

    initializer 'solidus_subscriptions.configs', before: "require subscription lib helpers" do
    end

    initializer 'register_subscription_promotion_rule', after: 'spree.promo.register.promotion.rules' do |app|
      app.config.spree.promotions.rules << 'SolidusSubscriptions::SubscriptionPromotionRule'
      app.config.spree.promotions.rules << 'SolidusSubscriptions::SubscriptionOrderPromotionRule'
    end

    initializer 'subscriptions_backend' do
      next unless Spree::Backend::Config.respond_to?(:menu_items)
      Spree::Backend::Config.configure do |config|
        config.menu_items << config.class::MenuItem.new(
          [:subscriptions],
          'repeat',
          url: :admin_subscriptions_path,
          condition: ->{ can?(:admin, SolidusSubscriptions::Subscription) }
        )
      end
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/decorators/**/*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      Spree::Ability.register_ability(SolidusSubscriptions::Ability)
    end

    config.to_prepare(&method(:activate).to_proc)
  end

  def self.table_name_prefix
    'solidus_subscriptions_'
  end
end
