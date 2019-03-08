# frozen_string_literal: true

module SolidusSubscriptions
  module PermissionSets
    class SubscriptionDisplay < PermissionSets::Base
      def activate!
        can :display, SolidusSubscriptions::Subscription
      end
    end
  end
end
