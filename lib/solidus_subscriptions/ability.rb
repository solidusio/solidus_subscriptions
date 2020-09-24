# frozen_string_literal: true

module SolidusSubscriptions
  class Ability
    include CanCan::Ability

    def initialize(user)
      if user.has_spree_role?('admin')
        can(:manage, LineItem)
        can(:manage, Subscription)
      else
        can([:index, :show, :create, :update, :destroy, :skip, :cancel], Subscription, user_id: user.id)
        can([:index, :show, :create, :update, :destroy], LineItem) do |line_item, order|
          line_item.order.user == user || line_item.order == order
        end
      end
    end
  end
end
