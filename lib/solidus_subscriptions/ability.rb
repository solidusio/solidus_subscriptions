# frozen_string_literal: true

module SolidusSubscriptions
  class Ability
    include CanCan::Ability

    def initialize(user)
      alias_action :create, :read, :update, :destroy, to: :crud

      if user.has_spree_role?('admin')
        can(:manage, LineItem)
        can(:manage, Subscription)
      else
        can([:crud, :skip, :cancel], Subscription, user_id: user.id)
        can(:crud, LineItem) do |li, order|
          li.order.user == user || li.order == order
        end
      end
    end
  end
end
