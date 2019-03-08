# frozen_string_literal: true

module SolidusSubscriptions
  module PermissionSets
    class SubscriptionManagement < PermissionSets::Base
      def activate!
        can :manage, SolidusSubscriptions::Subscription
      end
    end
  end
end
