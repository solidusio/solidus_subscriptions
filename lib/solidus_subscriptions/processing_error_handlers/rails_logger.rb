# frozen_string_literal: true

module SolidusSubscriptions
  module ProcessingErrorHandlers
    class RailsLogger
      def self.call(exception, installment = nil)
        new(exception, installment).call
      end

      def initialize(exception, installment = nil)
        @exception = exception
        @installment = installment
      end

      def call
        Rails.logger.error("Error processing installment with ID=#{installment.id}:") if installment
        Rails.logger.error(exception.message)
      end

      private

      attr_reader :exception, :installment
    end
  end
end
