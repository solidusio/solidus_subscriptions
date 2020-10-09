# frozen_string_literal: true

module SolidusSubscriptions
  module PermissionSets
    class SubscriptionManagement < ::Spree::PermissionSets::Base
      def activate!
        can :manage, Subscription
        can :manage, LineItem
      end
    end
  end
end
