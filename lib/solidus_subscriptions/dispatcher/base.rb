# frozen_string_literal: true

module SolidusSubscriptions
  module Dispatcher
    class Base
      attr_reader :installment, :order

      def initialize(installment, order)
        @installment = installment
        @order = order
      end

      def dispatch
        raise NotImplementedError
      end
    end
  end
end
