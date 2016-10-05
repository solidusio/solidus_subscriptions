module SolidusSubscriptions
  class Ability
    include CanCan::Ability

    def initialize(user)
      can(:manage, LineItem) do |li, order|
        li.order.user == user || li.order == order
      end

      can(:manage, Subscription) { |s| s.user == user }
    end
  end
end
