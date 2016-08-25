# The subscription class is responsable for grouping together the
# information required for the system to place a subscriptions order on
# behalf of a specific user.
module SolidusSubscriptions
  class Subscription < ActiveRecord::Base
    belongs_to :user, class_name: Spree.user_class
    validates :user, presence: :true
  end
end
