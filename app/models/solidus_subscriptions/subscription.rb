# The subscription class is responsible for grouping together the
# information required for the system to place a subscriptions order on
# behalf of a specific user.
module SolidusSubscriptions
  class Subscription < ActiveRecord::Base
    include Interval

    PROCESSING_STATES = [:pending, :failed, :success]

    belongs_to :user, class_name: "::#{::Spree.user_class}"
    has_many :line_items, class_name: 'SolidusSubscriptions::LineItem', inverse_of: :subscription
    has_many :installments, class_name: 'SolidusSubscriptions::Installment'
    belongs_to :store, class_name: '::Spree::Store'
    belongs_to :shipping_address, class_name: '::Spree::Address', optional: true
    belongs_to :billing_address, class_name: '::Spree::Address', optional: true
    belongs_to :payment_method, class_name: '::Spree::PaymentMethod', optional: true
    belongs_to :payment_source, polymorphic: true, optional: true

    validates :user, presence: :true
    validates :skip_count, :successive_skip_count, presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :interval_length, numericality: { greater_than: 0 }
    validates :payment_method, presence: true, if: -> { payment_source }
    validates :payment_source, presence: true, if: -> { payment_method&.source_required? }

    accepts_nested_attributes_for :shipping_address
    accepts_nested_attributes_for :billing_address
    accepts_nested_attributes_for :line_items, allow_destroy: true, reject_if: ->(p) { p[:quantity].blank? }

    before_validation :set_payment_method
    before_update :update_actionable_date_if_interval_changed

    # Find all subscriptions that are "actionable"; that is, ones that have an
    # actionable_date in the past and are not invalid or canceled.
    scope :actionable, (lambda do
      where("#{table_name}.actionable_date <= ?", Time.zone.now).
        where.not(state: ["canceled", "inactive"])
    end)

    # Find subscriptions based on their processing state. This state is not a
    # model attribute.
    #
    # @param state [Symbol] One of :pending, :success, or failed
    #
    # pending: New subscriptions, never been processed
    # failed: Subscriptions which failed to be processed on the last attempt
    # success: Subscriptions which were successfully processed on the last attempt
    scope :in_processing_state, (lambda do |state|
      case state.to_sym
      when :success
        fulfilled.joins(:installments)
      when :failed
        fulfilled_ids = fulfilled.pluck(:id)
        where.not(id: fulfilled_ids)
      when :pending
        includes(:installments).where(solidus_subscriptions_installments: { id: nil })
      else
        raise ArgumentError.new("state must be one of: :success, :failed, :pending")
      end
    end)

    scope :fulfilled, (lambda do
      unfulfilled_ids = unfulfilled.pluck(:id)
      where.not(id: unfulfilled_ids)
    end)

    scope :unfulfilled, (lambda do
      joins(:installments).merge(Installment.unfulfilled)
    end)

    def self.ransackable_scopes(_auth_object = nil)
      [:in_processing_state]
    end

    def self.processing_states
      PROCESSING_STATES
    end

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

      event :activate do
        transition any - [:active] => :active
      end

      after_transition to: :active, do: :advance_actionable_date
    end

    # This method determines if a subscription may be canceled. Canceled
    # subcriptions will not be processed. By default subscriptions may always be
    # canceled. If this method is overridden to return false, the subscription
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
    # :pending_cancellation state instead of being canceled. Subscriptions
    # pending cancellation will still be processed.
    def can_be_canceled?
      return true if actionable_date.nil?
      (actionable_date - Config.minimum_cancellation_notice).future?
    end

    def skip
      check_successive_skips_exceeded
      check_total_skips_exceeded

      return if errors.any?

      advance_actionable_date
    end

    # This method determines if a subscription can be deactivated. A deactivated
    # subscription will not be processed. By default a subscription can be
    # deactivated if the end_date defined on
    # the subscription is less than the current date
    # In this case the subscription has been fulfilled and
    # should not be processed again. Subscriptions without an end_date
    # value cannot be deactivated.
    def can_be_deactivated?
      active? && end_date && actionable_date && actionable_date > end_date
    end

    # Get the date after the current actionable_date where this subscription
    # will be actionable again
    #
    # @return [Date] The current actionable_date plus 1 interval. The next
    #   date after the current actionable_date this subscription will be
    #   eligible to be processed.
    def next_actionable_date
      return nil unless active?
      new_date = (actionable_date || Time.zone.now)
      (new_date + interval).beginning_of_minute
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
      LineItemBuilder.new(line_items)
    end

    # The state of the last attempt to process an installment associated to
    # this subscription
    #
    # @return [String] pending if the no installments have been processed,
    #   failed if the last installment has not been fulfilled and, success
    #   if the last installment was fulfilled.
    def processing_state
      return 'pending' if installments.empty?
      installments.last.fulfilled? ? 'success' : 'failed'
    end

    def payment_method_to_use
      payment_method || user.wallet.default_wallet_payment_source&.payment_source&.payment_method
    end

    def payment_source_to_use
      if payment_method
        payment_source
      else
        user.wallet.default_wallet_payment_source&.payment_source
      end
    end

    def shipping_address_to_use
      shipping_address || user.ship_address
    end

    def billing_address_to_use
      billing_address || user.bill_address
    end

    def dummy_order_without_line_items
      order = ::Spree::Order.new(
        ship_address: shipping_address_to_use,
        bill_address: billing_address_to_use,
      )

      yield order if block_given?

      order.freeze
    end

    def dummy_order
      dummy_order_without_line_items do |order|
        order.line_items = LineItemBuilder.new(line_items.to_a).spree_line_items
      end
    end

    private

    def check_successive_skips_exceeded
      return unless Config.maximum_successive_skips

      if successive_skip_count >= Config.maximum_successive_skips
        errors.add(:successive_skip_count, :exceeded)
      end
    end

    def check_total_skips_exceeded
      return unless Config.maximum_total_skips

      if skip_count >= Config.maximum_total_skips
        errors.add(:skip_count, :exceeded)
      end
    end

    def update_actionable_date_if_interval_changed
      if persisted? && (interval_length_previously_changed? || interval_units_previously_changed?)
        base_date = if installments.any?
          installments.last.created_at
        else
          created_at
        end

        new_date = interval.since(base_date)

        if new_date < Time.zone.now
          # if the chosen base time plus the new interval is in the past, set
          # the actionable_date to be now to avoid confusion and possible
          # mis-processing.
          new_date = Time.zone.now
        end

        self.actionable_date = new_date
      end
    end

    def set_payment_method
      if payment_source
        self.payment_method = payment_source.payment_method
      end
    end
  end
end
