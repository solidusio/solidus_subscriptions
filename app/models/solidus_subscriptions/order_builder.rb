# This class is responsible for adding line items to order without going
# through order contents.
module SolidusSubscriptions
  class OrderBuilder
    attr_reader :order

    # Get a new instance of an OrderBuilder
    #
    # @param order [Spree::Order] The order to be built
    #
    # @return [SolidusSubscriptions::OrderBuilder]
    def initialize(order)
      @order = order
    end

    # Add line items to an order. If the order already
    # has a line item for a given variant_id, update the quantity. Otherwise
    # add the line item to the order.
    #
    # @param items [Array<Spree::LineItem>] The order to add the line item to
    # @return [Array<Spree::LineItem] The collection that was passed in
    def add_line_items(items)
      items.map { |item| add_item_to_order(item) }
    end

    private

    def add_item_to_order(new_item)
      line_item = order.line_items.detect do |li|
        li.variant_id == new_item.variant_id
      end

      if line_item
        line_item.increment!(:quantity, new_item.quantity)
      else
        order.line_items << new_item
      end
    end
  end
end
