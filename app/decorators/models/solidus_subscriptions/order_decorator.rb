module SolidusSubscriptions
  module OrderDecorator
    # Spree::Orders may contain many subscription_line_items. When the order is
    # finalized these subscription_line_items are converted into subscritpions.
    # The order needs to be able to get a list of associated subscription_line_items
    # to be able to populate the full subscriptions.
    def self.prepended(base)
      base.has_many :subscription_line_items, through: :line_items
    end

    def ensure_line_items_present
      super unless subscription_order?
    end

    def send_cancel_email
      super unless subscription_order?
    end

    # Once an order is finalized its subscriptions line items should be converted
    # into active subscriptions. This hooks into Spree::Order#finalize! and
    # passes all subscription_line_items present on the order to the Subscription
    # generator which will build and persist the subscriptions
    def finalize!
      ::SolidusSubscriptions::SubscriptionGenerator.group(subscription_line_items).each do |line_items|
        ::SolidusSubscriptions::SubscriptionGenerator.activate(line_items)
      end

      super
    end

    ::Spree::Order.prepend(self)
  end
end
