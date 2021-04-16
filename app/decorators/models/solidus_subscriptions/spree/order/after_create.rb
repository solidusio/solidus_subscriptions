# frozen_string_literal: true

module SolidusSubscriptions
  module Spree
    module Order
      module AfterCreate
        def ensure_line_items_present
          super unless subscription_order?
        end

        def send_cancel_email
          super unless subscription_order?
        end
      end
    end
  end
end

Spree::Order.prepend(SolidusSubscriptions::Spree::Order::AfterCreate)
