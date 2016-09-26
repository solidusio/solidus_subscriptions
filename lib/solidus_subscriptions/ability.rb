module SolidusSubscriptions
  class Ability
    include CanCan::Ability

    def initialize(user)
      can(:manage, LineItem) { |li| li.order.user == user }
      can(:manage, Subscription) { |s| s.user == user }
    end
  end
end
