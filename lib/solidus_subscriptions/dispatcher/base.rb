module SolidusSubscriptions
  module Dispatcher
    class Base
      attr_reader :installments, :order

      # Get a new instance of the FailureDispatcher
      #
      # @param installments [Array<SolidusSubscriptions::Installment>] The
      #   installments which have failed to be fulfilled
      #
      # @return [SolidusSubscriptions::FailureDispatcher]
      def initialize(installments, order = nil)
        @installments = installments
        @order = order
      end

      def dispatch
        notify
      end

      private

      def notify
        send_email_to_admin_if_failure

        Rails.logger.tagged('Event') do
          Rails.logger.info message_string
        end
      end

      def message
        raise 'A message should be set in subclasses of Dispatcher'
      end

      def send_email_to_admin_if_failure
        return if message_code == 'success' || Config.subscription_failure_notification_email_class.blank?

        Config.subscription_failure_notification_email_class
              .subscription_failure_email(subscription_failure_params).deliver_later
      end

      def message_string
        @message_string ||= message.squish.tr("\n", ' ')
      end

      def message_code
        @message_code ||= self.class.name.underscore.split('/').last.sub('_dispatcher','')
      end

      def subscription_failure_params
        {
          code: message_code,
          installments: installments,
          order: order
        }
      end
    end
  end
end
