# frozen_string_literal: true

module SolidusSubscriptions
  module Spree
    module Variant
      module VariantPrettyName
        def pretty_name
          name = product.name
          name += " - #{options_text}" if options_text.present?
          name
        end
      end
    end
  end
end

Spree::Variant.prepend(SolidusSubscriptions::Spree::Variant::VariantPrettyName)
