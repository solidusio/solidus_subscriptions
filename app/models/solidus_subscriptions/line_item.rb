# frozen_string_literal: true

# The LineItem class is responsible for associating Line items to subscriptions.  # It tracks the following values:
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
  class LineItem < ApplicationRecord
    include Interval

    belongs_to(
      :spree_line_item,
      class_name: '::Spree::LineItem',
      inverse_of: :subscription_line_items,
      optional: true,
    )
    has_one :order, through: :spree_line_item, class_name: '::Spree::Order'
    belongs_to(
      :subscription,
      class_name: 'SolidusSubscriptions::Subscription',
      inverse_of: :line_items,
      optional: true
    )
    belongs_to :subscribable, class_name: "::#{SolidusSubscriptions.configuration.subscribable_class}"

    validates :subscribable_id, presence: true
    validates :quantity, numericality: { greater_than: 0 }
    validates :interval_length, numericality: { greater_than: 0 }, unless: -> { subscription }
  end
end
