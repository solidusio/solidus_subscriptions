module Spree
  module WalletPaymentSources
    module PaymentSourceAttributes
      def payment_source_attributes=(attributes)
        source_type = attributes[:source_type]
        self.payment_source = source_type.constantize.new(attributes.except(:source_type)) if source_type.present?
      end
    end
  end
end

Spree::WalletPaymentSource.prepend(Spree::WalletPaymentSources::PaymentSourceAttributes)
