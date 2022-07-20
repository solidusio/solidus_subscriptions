# frozen_string_literal: true

# Once an order is finalized its subscriptions line items should be converted
# into active subscriptions. This hooks into Spree::Order#finalize! and
# passes all subscription_line_items present on the order to the Subscription
# generator which will build and persist the subscriptions
module SolidusSubscriptions
  module Spree
    module Order
      module FinalizeCreatesSubscriptions
        def self.finalize_method
          if Gem::Version.new(::Spree.solidus_version) >= Gem::Version.new('3.2.0.alpha')
            :finalize
          else
            :finalize!
          end
        end

        define_method finalize_method do
          SolidusSubscriptions::SubscriptionGenerator.call(self)
          super()
        end
      end
    end
  end
end

Spree::Order.prepend(SolidusSubscriptions::Spree::Order::FinalizeCreatesSubscriptions)
