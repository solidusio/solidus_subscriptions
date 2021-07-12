# frozen_string_literal: true

module SolidusSubscriptions
  module ProcessingErrorHandlers
    class RailsLogger
      def self.call(exception)
        new(exception).call
      end

      def initialize(exception)
        @exception = exception
      end

      def call
        Rails.logger.error exception.message
      end

      private

      attr_reader :exception
    end
  end
end
