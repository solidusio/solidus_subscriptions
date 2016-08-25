# The subscription class is responsable for grouping together the
# information required for the system to place a subscriptions order on
# behalf of a specific user.
module SolidusSubscriptions
  class Subscription < ActiveRecord::Base
    belongs_to :user, class_name: Spree.user_class
    has_one :line_item, class_name: 'SolidusSubscriptions::LineItem'
    has_many :installments, class_name: 'SolidusSubscriptions::Installment'

    validates :user, presence: :true
  end
end
