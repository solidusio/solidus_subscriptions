module SolidusSubscriptions
  module OrderRenewal
    class UserMismatchError < StandardError
      def initialize(installments)
        @installments = installments
      end

      def to_s
        <<-MSG.squish
        Installments must have the same user to be processed as a consolidated
        installment. Could not process installments:
        #{@installments.map(&:id).join(', ')}
        MSG
      end
    end
  end
end
