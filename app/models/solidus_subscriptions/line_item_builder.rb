# This class is responsible for taking SubscriptionLineItems and building
# them into Spree::LineItems which can be added to an order
module SolidusSubscriptions
  class LineItemBuilder
    attr_reader :subscription_line_items

    # Get a new instance of a LineItemBuilder
    #
    # @param subscription_line_items[Array<SolidusSubscriptions::LineItem>] The
    #   subscription line item to be converted into a Spree::LineItem
    #
    # @return [SolidusSubscriptions::LineItemBuilder]
    def initialize(subscription_line_items)
      @subscription_line_items = subscription_line_items
    end

    # Get a new (unpersisted) Spree::LineItem which matches the details of
    # :subscription_line_item
    #
    # @return [Array<Spree::LineItem>]
    def spree_line_items
      line_items = subscription_line_items.map do |subscription_line_item|
        variant = subscribables.fetch(subscription_line_item.subscribable_id)

        raise UnsubscribableError.new(variant) unless variant.subscribable?
        next unless variant.can_supply?(subscription_line_item.quantity)

        Spree::LineItem.new(variant: variant, quantity: subscription_line_item.quantity)
      end

      # Either all line items for an installment are fulfilled or none are
      line_items.all? ? line_items : []
    end

    private

    def subscribables
      return @subscribables if @subscribables

      ids = subscription_line_items.map(&:subscribable_id)
      @subscribables ||= Spree::Variant.find(ids).index_by(&:id)
    end
  end
end
