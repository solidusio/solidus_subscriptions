module Spree
  class VariantSerializer < ActiveModel::Serializer
    attributes :id, :sku, :options_text, :product_id, :price_hash

    has_one :product
    has_many :option_values

    def price_hash
      case Spree::Config.default_pricing_options.currency
      when 'USD'
        {
          cents: (object.price * 100).to_i,
          currency: 'USD',
        }
      else
        raise NotImplementedError, "Don't yet handle non-USD currencies"
      end
    end
  end
end
