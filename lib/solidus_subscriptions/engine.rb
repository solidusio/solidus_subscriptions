module SolidusSubscriptions
  class Engine < Rails::Engine
    require 'spree/core'

    isolate_namespace SolidusSubscriptions
    engine_name 'solidus_subscriptions'

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer 'solidus_subscriptions.configs', before: "spree.register.payment_methods" do
      require 'solidus_subscriptions/config'
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
