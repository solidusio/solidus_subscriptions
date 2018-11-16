module Spree
  module WalletPaymentSources
    module NestedAttributesForPaymentSource
      def self.prepended(base)
        base.accepts_nested_attributes_for :payment_source
      end
    end
  end
end

Spree::WalletPaymentSource.prepend(Spree::WalletPaymentSources::NestedAttributesForPaymentSource)
