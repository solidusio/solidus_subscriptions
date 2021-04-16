# frozen_string_literal: true

module SolidusSubscriptions
  module Spree
    module Variant
      module AutoDeleteFromSubscriptions
        def self.prepended(base)
          base.after_discard(:remove_from_subscriptions)
          base.after_destroy(:remove_from_subscriptions)
        end

        def remove_from_subscriptions
          SolidusSubscriptions::LineItem.where(subscribable: self).delete_all
        end

        ::Spree::Variant.prepend self
      end
    end
  end
end
