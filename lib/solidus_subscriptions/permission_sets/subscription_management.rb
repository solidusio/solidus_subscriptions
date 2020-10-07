# frozen_string_literal: true

module SolidusSubscriptions
  module PermissionSets
    class SubscriptionManagement < ::Spree::PermissionSets::Base
      def activate!
        can :manage, Subscription do |subscription|
          subscription.user == user
        end

        can :manage, LineItem do |line_item, order|
          (line_item.order && line_item.order == order) ||
            (line_item.order&.user && line_item.order.user == user)
        end
      end
    end
  end
end
