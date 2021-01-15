# frozen_string_literal: true

# This class represents a single iteration of a subscription. It is fulfilled
# by a completed order and maintains an association which tracks all attempts
# successful or otherwise at fulfilling this installment
module SolidusSubscriptions
  class Installment < ApplicationRecord
    has_many :details, class_name: 'SolidusSubscriptions::InstallmentDetail'
    belongs_to(
      :subscription,
      class_name: 'SolidusSubscriptions::Subscription',
      inverse_of: :installments,
    )

    validates :subscription, presence: true

    scope :fulfilled, (lambda do
      joins(:details).where(InstallmentDetail.table_name => { success: true }).distinct
    end)

    scope :unfulfilled, (lambda do
      fulfilled_ids = fulfilled.pluck(:id)
      where.not(id: fulfilled_ids).distinct
    end)

    scope :with_active_subscription, (lambda do
      joins(:subscription).where.not(Subscription.table_name => { state: "canceled" })
    end)

    scope :actionable, (lambda do
      unfulfilled.where("#{table_name}.actionable_date <= ?", Time.zone.today)
    end)

    # Get the builder for the subscription_line_item. This will be an
    # object that can generate the appropriate line item for the subscribable
    # object
    #
    # @return [SolidusSubscriptions::LineItemBuilder]
    delegate :line_item_builder, to: :subscription

    # Mark this installment as out of stock.
    #
    # @return [SolidusSubscriptions::InstallmentDetail] The record of the failed
    #   processing attempt
    def out_of_stock
      advance_actionable_date!

      details.create!(
        success: false,
        message: I18n.t('solidus_subscriptions.installment_details.out_of_stock')
      )
    end

    # Mark this installment as a success
    #
    # @param order [Spree::Order] The order generated for this processing
    #   attempt
    #
    # @return [SolidusSubscriptions::InstallmentDetail] The record of the
    #   successful processing attempt
    def success!(order)
      update!(actionable_date: nil)

      details.create!(
        success: true,
        order: order,
        message: I18n.t('solidus_subscriptions.installment_details.success')
      )
    end

    # Mark this installment as a failure
    #
    # @param order [Spree::Order] The order generated for this processing
    #   attempt
    #
    # @return [SolidusSubscriptions::InstallmentDetail] The record of the
    #   failed processing attempt
    def failed!(order)
      advance_actionable_date!

      details.create!(
        success: false,
        order: order,
        message: I18n.t('solidus_subscriptions.installment_details.failed')
      )
    end

    # Does this installment still need to be fulfilled by a completed order
    #
    # @return [Boolean]
    def unfulfilled?
      !fulfilled?
    end

    # Had this installment been fulfilled by a completed order
    #
    # @return [Boolean]
    def fulfilled?
      details.exists?(success: true)
    end

    # Returns the state of this fulfillment
    #
    # @return [Symbol] :fulfilled/:unfulfilled
    def state
      fulfilled? ? :fulfilled : :unfulfilled
    end

    # Mark this installment as having a failed payment
    #
    # @param order [Spree::Order] The order generated for this processing
    #   attempt
    #
    # @return [SolidusSubscriptions::InstallmentDetail] The record of the
    #   failed processing attempt
    def payment_failed!(order)
      details.create!(
        success: false,
        order: order,
        message: I18n.t('solidus_subscriptions.installment_details.payment_failed')
      )

      if subscription.maximum_reprocessing_time_reached? && !subscription.canceled?
        subscription.force_cancel!
        update!(actionable_date: nil)
      else
        advance_actionable_date!
      end
    end

    private

    def advance_actionable_date!
      update!(actionable_date: next_actionable_date)
    end

    def next_actionable_date
      return if SolidusSubscriptions.configuration.reprocessing_interval.nil?

      (DateTime.current + SolidusSubscriptions.configuration.reprocessing_interval).beginning_of_minute
    end
  end
end
