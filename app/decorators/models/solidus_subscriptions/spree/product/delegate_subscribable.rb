# frozen_string_literal: true

module SolidusSubscriptions
  module Spree
    module Product
      module DelegateSubscribable
        def self.prepended(base)
          base.class_eval do
            delegate :subscribable, :subscribable=, to: :find_or_build_master
          end
        end
      end
    end
  end
end

Spree::Product.prepend(SolidusSubscriptions::Spree::Product::DelegateSubscribable)
