# frozen_string_literal: true

module SolidusSubscriptions
  module Spree
    module Order
      module InstallmentDetailsAssociation
        def self.prepended(base)
          base.has_many :installment_details, class_name: '::SolidusSubscriptions::InstallmentDetail'
        end
      end
    end
  end
end

Spree::Order.prepend(SolidusSubscriptions::Spree::Order::InstallmentDetailsAssociation)
