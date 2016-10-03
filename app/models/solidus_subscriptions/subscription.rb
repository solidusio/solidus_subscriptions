# The subscription class is responsable for grouping together the
# information required for the system to place a subscriptions order on
# behalf of a specific user.
module SolidusSubscriptions
  class Subscription < ActiveRecord::Base
    belongs_to :user, class_name: Spree.user_class
    has_one :line_item, class_name: 'SolidusSubscriptions::LineItem'
    has_many :installments, class_name: 'SolidusSubscriptions::Installment'
    has_one :root_order, through: :line_item, class_name: 'Spree::Order', source: :order

    validates :user, presence: :true

    accepts_nested_attributes_for :line_item

    # The following methods are delegated to the associated
    # SolidusSubscriptions::LineItem
    #
    # :interval, :quantity, :subscribable_id, :max_installments
    delegate :interval, :quantity, :subscribable_id, :max_installments, to: :line_item

    # Find all subscriptions that are "actionable"; that is, ones that have an
    # actionable_date in the past and are not invalid or canceled.
    scope :actionable, (lambda do
      where("#{table_name}.actionable_date < ?", Time.zone.now).
        where.not(state: ["canceled", "inactive"])
    end)

    # The subscription state determines the behaviours around when it is
    # processed. Here is a brief description of the states and how they affect
    # the subscription.
    #
    # [active] Default state when created. Subscription can be processed
    # [canceled] The user has ended their subscription. Subscription will not
    #   be processed.
    # [pending_cancellation] The user has ended their subscription, but the
    #   conditions for canceling the subscription have not been met. Subscription
    #   will continue to be processed until the subscription is canceled and
    #   the conditions are met.
    # [inactive] The number of installments has been fulfilled. The subscription
    #   will no longer be processed
    state_machine :state, initial: :active do
      event :cancel do
        transition [:active, :pending_cancellation] => :canceled,
          if: ->(subscription) { subscription.can_be_canceled? }

        transition active: :pending_cancellation
      end

      after_transition to: :canceled, do: :advance_actionable_date

      event :deactivate do
        transition active: :inactive,
          if: ->(subscription) { subscription.can_be_deactivated? }
      end
    end

    # This method determines if a subscription may be canceled. Canceled
    # subcriptions will not be processed. By default subscriptions may always be
    # canceled. If this method is overriden to return false, the subscription
    # will be moved to the :pending_cancellation state until it is canceled
    # again and this condition is true.
    #
    # USE CASE: Subscriptions can only be canceled more than 10 days before they
    # are processed. Override this method to be:
    #
    # def can_be_canceled?
    #   return true if actionable_date.nil?
    #   (actionable_date - 10.days.from_now.to_date) > 0
    # end
    #
    # If a user cancels this subscription less than 10 days before it will
    # be processed the subscription will be bumped into the
    # :pending_cancellation state instead of being canceled. Susbcriptions
    # pending cancellation will still be processed.
    def can_be_canceled?
      return true if actionable_date.nil?
      (actionable_date - Config.minimum_cancellation_notice).future?
    end

    # This method determines if a subscription can be deactivated. A deactivated
    # subscription will not be processed. By default a subscription can be
    # deactivated if the number of max_installments defined on the
    # subscription_line_item is equal to the number of installments associated
    # to the subscription. In this case the subscription has been fulfilled and
    # should not be processed again. Subscriptions without a max_installment
    # value cannot be deactivated.
    def can_be_deactivated?
      return false if line_item.max_installments.nil?
      installments.count >= line_item.max_installments
    end

    # Get the date after the current actionable_date where this subscription
    # will be actionable again
    #
    # @return [Date] The current actionable_date plus 1 interval. The next
    #   date after the current actionable_date this subscription will be
    #   eligible to be processed.
    def next_actionable_date
      return nil unless active?
      (actionable_date || Time.zone.now) + interval
    end

    # Advance the actionable date to the next_actionable_date value. Will modify
    # the record.
    #
    # @return [Date] The next date after the current actionable_date this
    # subscription will be eligible to be processed.
    def advance_actionable_date
      update! actionable_date: next_actionable_date
      actionable_date
    end

    # Get the builder for the subscription_line_item. This will be an
    # object that can generate the appropriate line item for the subscribable
    # object
    #
    # @return [SolidusSubscriptions::LineItemBuilder]
    def line_item_builder
      LineItemBuilder.new(line_item)
    end
  end
end
