# frozen_string_literal: true

module SolidusSubscriptions
  module Dispatcher
    class SuccessDispatcher < Base
      def dispatch
        installment.success!(order)

        ::SolidusSupport::LegacyEventCompat::Bus.publish(
          :'solidus_subscriptions.installment_succeeded',
          installment: installment,
          order: order,
        )
      end
    end
  end
end
