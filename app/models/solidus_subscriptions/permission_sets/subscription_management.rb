# frozen_string_literal: true

module SolidusSubscriptions
  module PermissionSets
    class SubscriptionManagement < ::Spree::PermissionSets::Base
      class << self
        def privilege
          :manage
        end

        def category
          :subscription
        end
      end

      def activate!
        can :manage, Subscription
        can :manage, LineItem
      end
    end
  end
end
