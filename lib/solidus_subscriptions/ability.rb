module SolidusSubscriptions
  class Ability
    include CanCan::Ability

    def initialize(user)
      can(:manage, LineItem) do |li, order|
        li.order.user == user || li.order == order
      end

      can(:manage, Subscription, user_id: user.id)
    end
  end
end
