# frozen_string_literal: true

module SolidusSubscriptions
  module Dispatcher
    class Base
      attr_reader :installments, :order

      # Returns a new instance of this dispatcher.
      #
      # @param installments [Array<SolidusSubscriptions::Installment>] The installments to process
      #   with this dispatcher
      # @param order [Spree::Order] The order that was generated as a result of these installments
      #
      # @return [SolidusSubscriptions::Dispatcher]
      def initialize(installments, order = nil)
        @installments = installments
        @order = order
      end

      def dispatch
        raise NotImplementedError
      end
    end
  end
end
