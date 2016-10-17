# This class is responsible for taking a SubscriptionLineItem and building
# it into a Spree::LineItem which can be added to an order
module SolidusSubscriptions
  class LineItemBuilder
    attr_reader :subscription_line_item

    # Get a new instance of a LineItemBuilder
    #
    # @param subscription_line_item [SolidusSubscriptions::LineItem] The
    #   subscription line item to be converted into a Spree::LineItem
    #
    # @return [SolidusSubscriptions::LineItemBuilder]
    def initialize(subscription_line_item)
      @subscription_line_item = subscription_line_item
    end

    # Get a new (unpersisted) Spree::LineItem which matches the details of
    # :subscription_line_item
    #
    # @return [Spree::LineItem]
    def line_item
      variant = Spree::Variant.find(subscription_line_item.subscribable_id)
      raise UnsubscribableError.new(variant) unless variant.subscribable?
      return unless variant.can_supply?(subscription_line_item.quantity)

      Spree::LineItem.new(variant: variant, quantity: subscription_line_item.quantity)
    end
  end
end
