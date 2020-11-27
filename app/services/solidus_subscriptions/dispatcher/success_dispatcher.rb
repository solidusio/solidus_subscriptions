# frozen_string_literal: true

# Handles installments that are processed successfully.
module SolidusSubscriptions
  module Dispatcher
    class SuccessDispatcher < Base
      def dispatch
        installments.each do |installment|
          installment.success!(order)
        end

        ::Spree::Event.fire(
          'solidus_subscriptions.installments_succeeded',
          installments: installments,
          order: order,
        )
      end
    end
  end
end
