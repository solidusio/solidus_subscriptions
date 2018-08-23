# This class takes a collection of installments and populates a new spree
# order with the correct contents based on the subscriptions associated to the
# intallments. This is to group together subscriptions being
# processed on the same day for a specific user
module SolidusSubscriptions
  class Checkout
    # @return [Array<Installment>] The collection of installments to be used
    #   when generating a new order
    attr_reader :installments

    delegate :user, to: :subscription

    # Get a new instance of a Checkout
    #
    # @param installments [Array<Installment>] The collection of installments
    # to be used when generating a new order
    def initialize(installments)
      @installments = installments
      raise UserMismatchError.new(installments) if different_owners?
    end

    # Generate a new Spree::Order based on the information associated to the
    # installments
    #
    # @return [Spree::Order]
    def process
      populate

      # Installments are removed and set for future processing if they are
      # out of stock. If there are no line items left there is nothing to do
      return if installments.empty?

      if checkout
        Config.success_dispatcher_class.new(installments, order).dispatch
        return order
      end

      # A new order will only have 1 payment that we created
      if order.payments.any?(&:failed?)
        Config.payment_failed_dispatcher_class.new(installments, order).dispatch
        installments.clear
        nil
      end
    ensure
      # Any installments that failed to be processed will be reprocessed
      unfulfilled_installments = installments.select(&:unfulfilled?)
      if unfulfilled_installments.any?
        Config.failure_dispatcher_class.
          new(unfulfilled_installments, order).dispatch
      end
    end

    # The order fulfilling the consolidated installment
    #
    # @return [Spree::Order]
    def order
      @order ||= Spree::Order.create(
        user: user,
        email: user.email,
        store: subscription.store || Spree::Store.default,
        subscription_order: true
      )
    end

    private

    def checkout
      order.update!
      apply_promotions

      order.checkout_steps[0...-1].each do
        order.ship_address = ship_address if order.state == "address"
        create_payment if order.state == "payment"
        order.next!
      end

      # Do this as a separate "quiet" transition so that it returns true or
      # false rather than raising a failed transition error
      order.complete
    end

    def populate
      unfulfilled_installments = []

      order_line_items = installments.flat_map do |installment|
        line_items = installment.line_item_builder.spree_line_items

        unfulfilled_installments.push(installment) if line_items.empty?

        line_items
      end

      # Remove installments which had no stock from the active list
      # They will be reprocessed later
      @installments -= unfulfilled_installments
      if unfulfilled_installments.any?
        Config.out_of_stock_dispatcher_class.new(unfulfilled_installments).dispatch
      end

      return if installments.empty?
      order_builder.add_line_items(order_line_items)
    end

    def order_builder
      @order_builder ||= OrderBuilder.new(order)
    end

    def subscription
      installments.first.subscription
    end

    def ship_address
      subscription.shipping_address || user.ship_address
    end

    def active_card
      if SolidusSupport.solidus_gem_version <  Gem::Version.new("2.2.0")
        user.credit_cards.default.last
      else
        user.wallet.default_wallet_payment_source.payment_source
      end
    end

    def create_payment
      order.payments.create(
        source: active_card,
        amount: order.total,
        payment_method: Config.default_gateway
      )
    end

    def apply_promotions
      Spree::PromotionHandler::Cart.new(order).activate
      order.updater.update # reload totals
    end

    def different_owners?
      installments.map { |i| i.subscription.user }.uniq.length > 1
    end
  end
end
