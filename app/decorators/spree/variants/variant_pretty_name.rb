module Spree
  module Variants
    module VariantPrettyName
      def pretty_name
        name = product.name
        name += " - #{options_text}" if options_text.present?
        name
      end
    end
  end
end

Spree::Variant.prepend Spree::Variants::VariantPrettyName
