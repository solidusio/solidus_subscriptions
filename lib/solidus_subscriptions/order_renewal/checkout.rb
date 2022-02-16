# This class takes a collection of installments and populates a new spree
# order with the correct contents based on the subscriptions associated to the
# intallments. This is to group together subscriptions being
# processed on the same day for a specific user
module SolidusSubscriptions
  module OrderRenewal
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
        line_items = process_installments
        # Installments are removed and set for future processing if they are
        # out of stock. If there are no line items left there is nothing to do
        return if line_items.blank?

        order = create_order

        begin
          populate(order, line_items)
          finalize(order)

          Config.success_dispatcher_class.new(installments, order).dispatch
        rescue StateMachines::InvalidTransition
          if order.payments.any?(&:failed?) ||       # CreditCard payment is failed, or
             order.payments.not_store_credits.empty? # StoreCredits amount is less than an order total
            Config.payment_failed_dispatcher_class.new(installments, order).dispatch
          else
            Config.failure_dispatcher_class.new(installments, order).dispatch
          end
        rescue ::Spree::Order::InsufficientStock
          Config.out_of_stock_dispatcher_class.new(installments, order).dispatch
        rescue
          Config.admin_dispatcher_class.new(installments, order).dispatch
        end

        order
      end

      def create_order
        Config.order_creator_class.new(subscription).call
      end

      private

      def finalize(order)
        order.recalculate
        apply_promotions(order)

        order.checkout_steps[0...-1].each do
          case order.state
          when 'address'
            order.ship_address = ship_address
          when 'payment'
            create_payment(order)
          end

          order.next!
        end

        order.complete!
      end

      def process_installments
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

        order_line_items
      end

      def populate(order, line_items)
        OrderBuilder.new(order).add_line_items(line_items)
      end

      def subscription
        installments.first.subscription
      end

      def ship_address
        subscription.shipping_address || user.ship_address
      end

      def active_card
        @active_card ||= user.wallet.default_wallet_payment_source&.payment_source
      end

      def create_payment(order)
        order.payments.create(
          source: active_card,
          amount: order.total,
          payment_method: Config.default_gateway
        )
      end

      def apply_promotions(order)
        Spree::PromotionHandler::Cart.new(order).activate
        order.updater.update # reload totals
      end

      def different_owners?
        installments.map { |i| i.subscription.user }.uniq.length > 1
      end
    end
  end
end
