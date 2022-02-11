# This class represents a single iteration of a subscription. It is fulfilled
# by a completed order and maintains an association which tracks all attempts
# successful or otherwise at fulfilling this installment
module SolidusSubscriptions
  class Installment < ActiveRecord::Base
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
      fulfilled_ids = fulfilled.select(:id)
      where.not(id: fulfilled_ids).distinct
    end)

    scope :actionable, (lambda do
      unfulfilled.where("#{table_name}.actionable_date <= ?", Time.zone.now)
    end)

    scope :with_active_subscription, (lambda do
      joins(:subscription).where.not(Subscription.table_name => { state: "canceled" })
    end)

    # Get the builder for the subscription_line_item. This will be an
    # object that can generate the appropriate line item for the subscribable
    # object
    #
    # @return [SolidusSubscriptions::LineItemBuilder]
    def line_item_builder
      subscription.line_item_builder
    end

    # Mark this installment as out of stock.
    #
    # @return [SolidusSubscriptions::InstallmentDetail] The record of the failed
    #   processing attempt
    def out_of_stock
      failure_handler('out_of_stock')
    end

    # Mark this installment as a success
    #
    # @param order [Spree::Order] The order generated for this processing
    #   attempt
    #
    # @return [SolidusSubscriptions::InstallmentDetail] The record of the
    #   successful processing attempt
    def success!(order)
      advance_actionable_date!(false)

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
      failure_handler('failed', order: order)
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
      details.where(success: true).exists?
    end

    # Mark this installment as having a failed payment
    #
    # @param order [Spree::Order] The order generated for this processing
    #   attempt
    #
    # @return [SolidusSubscriptions::InstallmentDetail] The record of the
    #   failed processing attempt
    def payment_failed!(order)
      failure_handler('payment_failed', order: order).tap do |_installment_details|
        unless Config.failed_subscriptions_limit.zero?
          prev_details = details.history(last: Config.failed_subscriptions_limit).to_a
          if prev_details.all?(&:failed?) && prev_details.size == Config.failed_subscriptions_limit && subscription.active?
            subscription.transaction do
              subscription.actionable_date = nil
              subscription.cancel
            end
          end
        end
      end

    end

    private

    def advance_actionable_date!(flag = true)
      update!(actionable_date: flag ? next_actionable_date : nil)
    end

    def next_actionable_date
      return if Config.reprocessing_interval.nil?
      (DateTime.current + Config.reprocessing_interval).beginning_of_minute
    end

    def failure_handler(err_code, order: nil)
      advance_actionable_date! if_failure_threshold_not_exceeded

      details.create!(
        success: false,
        err_code: err_code,
        order: order,
        message: I18n.t(err_code, scope: 'solidus_subscriptions.installment_details')
      )
    end

    def if_failure_threshold_not_exceeded
      !failure_threshold_exceeded?
    end

    def failure_threshold_exceeded?
      return unless Config.maximum_total_failure_skips

      prev_details = details.history(last: Config.maximum_total_failure_skips)
      failure_threshold = Config.maximum_total_failure_skips - 1 # The current failure is not registered yet.
      prev_details.all?(&:failed?) && prev_details.size >= failure_threshold
    end
  end
end
