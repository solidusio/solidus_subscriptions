module SolidusSubscriptions
  module VariantDecorator
    def pretty_name
      name = product.name
      name += " - #{options_text}" if options_text.present?
      name
    end

    ::Spree::Variant.prepend self
  end
end

