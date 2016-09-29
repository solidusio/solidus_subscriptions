# This class takes a collection of installments and populates a new spree
# order with the correct contents based on the subscriptions associated to the
# intallments. This is to group together subscriptions being
# processed on the same day for a specific user
module SolidusSubscriptions
  class ConsolidatedInstallment
    # @return [Array<Installment>] The collection of installments to be used
    #   when generating a new order
    attr_reader :installments

    delegate :user, :root_order, to: :subscription

    # Get a new instance of a ConsolidatedInstallment
    #
    # @param [Array<Installment>] :installments, The collection of installments
    # to be used when generating a new order
    def initialize(installments)
      @installments = installments
    end

    # Generate a new Spree::Order based on the information associated to the
    # installments
    #
    # @return [Spree::Order]
    def process
      ActiveRecord::Base.transaction do
        populate

        # Installments are removed and set for future processing if they are
        # out of stock. If there are no line items left there is nothing to do
        return if installments.empty?

        if checkout
          # Associate the order with the fulfilled installments
          installments.each { |installment| installment.update!(order_id: order.id) }
          SuccessDispatcher.new(installments).dispatch
          return order
        end

        # A new order will only have 1 payment that we created
        if order.payments.any?(&:failed?)
          PaymentFailedDispatcher.new(installments).dispatch
          installments.clear
          order.destroy!
          nil
        end
      end
    ensure
      # Any installments that failed to be processed will be reprocessed
      FailureDispatcher.new(installments.select(&:unfulfilled?)).dispatch
    end

    # The order fulfilling the consolidated installment
    #
    # @return [Spree::Order]
    def order
      @order ||= Spree::Order.create(
        user: user,
        email: user.email,
        store: root_order.store
      )
    end

    private

    def checkout
      order.next! # cart => address

      order.ship_address = ship_address
      order.next! # address => delivery
      order.next! # delivery => payment

      create_payment
      order.next! # payment => confirm

      # Do this as a separate "quiet" transition so that it returns true or
      # false rather than raising a failed transition error
      order.complete
    end

    def populate
      unfulfilled_installments = []

      line_items = installments.map do |installment|
        line_item = installment.line_item_builder.line_item

        if line_item.nil?
          unfulfilled_installments << installment
          next
        end

        line_item
      end.
      compact

      # Remove installments which had no stock from the active list
      # They will be reprocessed later
      @installments -= unfulfilled_installments
      OutOfStockDispatcher.new(unfulfilled_installments).dispatch

      return if installments.empty?
      order_builder.add_line_items(line_items)
    end

    def order_builder
      @order_builder ||= OrderBuilder.new(order)
    end

    def subscription
      installments.first.subscription
    end

    def ship_address
      user.ship_address || root_order.ship_address
    end

    def active_card
      user.credit_cards.default.last || root_order.credit_cards.last
    end

    def create_payment
      order.payments.create(
        source: active_card,
        amount: order.total,
        payment_method: Config.default_gateway
      )
    end
  end
end
