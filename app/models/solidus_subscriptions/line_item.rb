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

    # The name of the variant which will eventually fulfill this line item
    #
    # @return [String]
    def name
      dummy_line_item.name
    end

    def price
      dummy_line_item.price
    end

    def next_actionable_date
      dummy_subscription.next_actionable_date
    end

    private

    # Get a placeholder line item for calculating the values of future
    # subscription orders. It associates to a frozen order and cannot be saved
    def dummy_line_item
      @dummy_line_item ||= dummy_subscription.line_item_builder.line_item.tap do |li|
        li.order = dummy_order
        li.validate
      end
    end

    # Get a placeholder order for calculating the values of future
    # subscription orders. It is a frozen duplicate of the current order and
    # cannot be saved
    def dummy_order
      @dummy_order ||= spree_line_item.order.dup.freeze
    end

    # A place holder for calculating dynamic values needed to display in the cart
    # it is frozen and cannot be saved
    def dummy_subscription
      @dummy_subscritpion ||= Subscription.new(line_item: self).freeze
    end
  end
end
