module SolidusSubscriptions
  class Ability
    include CanCan::Ability

    def initialize(user)
      can(:manage, SolidusSubscriptions::LineItem) { |li| li.order.user == user }
    end
  end
end
