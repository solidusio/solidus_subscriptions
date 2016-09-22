# The LineItem class is responsible for associating Line items to subscriptions.
# It tracks the following values:
#
# [Spree::LineItem] :spree_line_item The spree object which created this instance
#
# [SolidusSubscription::Subscription] :subscription The object responsible for
#   grouping all information needed to create new subscription orders together
#
# [Integer] :subscribable_id The id of the object to be added to new subscription
#   orders when they are placed
#
# [Integer] :quantity How many units of the subscribable should be included in
#   future orders
#
# [Integer] :interval How often subscription orders should be placed
#
# [Integer] :installments How many subscription orders should be placed
module SolidusSubscriptions
  class LineItem < ActiveRecord::Base
    belongs_to :spree_line_item, class_name: 'Spree::LineItem', inverse_of: :subscription_line_items
    has_one :order, through: :spree_line_item, class_name: 'Spree::Order'
    belongs_to(
      :subscription,
      class_name: 'SolidusSubscriptions::Subscription',
      inverse_of: :line_item
    )

    enum interval_units: [
      :days,
      :weeks,
      :months,
      :years
    ]

    validates :spree_line_item, :subscribable_id, presence: :true
    validates :quantity, :interval_length, numericality: { greater_than: 0 }
    validates :max_installments, numericality: { greater_than: 0 }, allow_blank: true

    # Calculates the number of seconds in the interval.
    #
    # @return [Integer] The number of seconds.
    def interval
      ActiveSupport::Duration.new(interval_length, { interval_units.to_sym => interval_length })
    end
  end
end
