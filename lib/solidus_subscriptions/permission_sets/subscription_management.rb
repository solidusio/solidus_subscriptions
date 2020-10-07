# frozen_string_literal: true

module SolidusSubscriptions
  module PermissionSets
    class SubscriptionManagement < ::Spree::PermissionSets::Base
      def activate!
        can :manage, Subscription do |subscription|
          subscription.user && subscription.user == user
        end

        can :manage, LineItem do |line_item|
          line_item.subscription&.user && line_item.subscription.user == user
        end
      end
    end
  end
end
