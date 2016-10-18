module Spree
  module Orders
    module AfterCreate
      def ensure_line_items_present
        super unless subscription_order?
      end

      def send_cancel_email
        super unless subscription_order?
      end
    end

    Order.prepend(AfterCreate)
  end
end
