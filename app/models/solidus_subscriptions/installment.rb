# This class represents a single iteration of a subscription. It is fulfulled
# by a conmpleted order and maintains an association which tracks all attempts
# successful or othewise at fulfulling this installment
module SolidusSubscriptions
  class Installment < ActiveRecord::Base
    belongs_to :order, class_name: 'Spree::Order'
    belongs_to(
      :subscription,
      class_name: 'SolidusSubscriptions::Subscription',
      inverse_of: :installments
    )

    validates :subscription, presence: true
  end
end
