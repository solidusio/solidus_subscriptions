# This class represents a single iteration of a subscription. It is fulfulled
# by a conmpleted order and maintains an association which tracks all attempts
# successful or othewise at fulfulling this installment
module SolidusSubscriptions
  class Installment < ActiveRecord::Base
    has_many :details, class_name: 'SolidusSubscriptions::InstallmentDetail'
    belongs_to :order, class_name: 'Spree::Order'
    belongs_to(
      :subscription,
      class_name: 'SolidusSubscriptions::Subscription',
      inverse_of: :installments
    )

    validates :subscription, presence: true

    # Get the builder for the subscription_line_item. This will be an
    # object that can generate the appropriate line item for the subscribable
    # object
    #
    # @return [SolidusSubscriptions::LineItemBuilder]
    def line_item_builder
      LineItemBuilder.new(subscription.line_item)
    end

    # Mark this installment as out of stock.
    #
    # @return [SolidusSubscriptions::InstallmentDetail] The record of the failed
    #   processing attempt
    def out_of_stock
      advance_actionable_date

      details.create!(
        success: false,
        message: I18n.t('solidus_subscriptions.installment_details.out_of_stock')
      )
    end

    # Mark this installment as a success
    #
    # @return [SolidusSubscriptions::InstallmentDetail] The record of the
    #   successful processing attempt
    def success!
      update!(actionable_date: nil)

      details.create!(
        success: true,
        message: I18n.t('solidus_subscriptions.installment_details.success')
      )
    end

    private

    def advance_actionable_date
      update(actionable_date: next_actionable_date)
    end

    def next_actionable_date
      Date.today + Config.reprocessing_interval
    end
  end
end
