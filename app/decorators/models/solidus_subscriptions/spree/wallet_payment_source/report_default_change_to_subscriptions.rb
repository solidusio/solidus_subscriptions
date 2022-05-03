# frozen_string_literal: true

module SolidusSubscriptions
  module Spree
    module WalletPaymentSource
      module ReportDefaultChangeToSubscriptions
        def self.prepended(base)
          base.after_save :report_default_change_to_subscriptions
        end

        private

        def report_default_change_to_subscriptions
          return if !previous_changes.key?('default') || !default?

          user.subscriptions.with_default_payment_source.each do |subscription|
            ::SolidusSupport::LegacyEventCompat::Bus.publish(
              :'solidus_subscriptions.subscription_payment_method_changed',
              subscription: subscription,
            )
          end
        end
      end
    end
  end
end

Spree::WalletPaymentSource.prepend(SolidusSubscriptions::Spree::WalletPaymentSource::ReportDefaultChangeToSubscriptions)
