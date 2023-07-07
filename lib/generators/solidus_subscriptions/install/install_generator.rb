# frozen_string_literal: true

module SolidusSubscriptions
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      class_option :auto_run_migrations, type: :boolean, default: false
      # Either 'starter' or 'classic'
      class_option :frontend, type: :string, default: 'starter'

      def copy_initializer
        template 'initializer.rb', 'config/initializers/solidus_subscriptions.rb'
      end

      def add_javascripts
        append_file 'vendor/assets/javascripts/spree/backend/all.js', "//= require spree/backend/solidus_subscriptions\n"
      end

      def copy_starter_frontend_files
        return if options[:frontend] != 'starter'

        copy_file 'app/views/cart_line_items/_subscription_fields.html.erb'
        prepend_to_file 'app/views/cart_line_items/_product_submit.html.erb', "<%= render 'cart_line_items/subscription_fields' %>\n"

        copy_file 'app/controllers/concerns/create_subscription.rb'
        insert_into_file 'app/controllers/cart_line_items_controller.rb', after: "class CartLineItemsController < StoreController\n" do
          <<~RUBY.indent(2)
            include CreateSubscription

          RUBY
        end
      end

      def add_migrations
        run 'bin/rails railties:install:migrations FROM=solidus_subscriptions'
      end

      def run_migrations
        run_migrations = options[:auto_run_migrations] || ['', 'y', 'Y'].include?(ask('Would you like to run the migrations now? [Y/n]'))
        if run_migrations
          run 'bin/rails db:migrate'
        else
          puts 'Skipping bin/rails db:migrate, don\'t forget to run it!' # rubocop:disable Rails/Output
        end
      end
    end
  end
end
