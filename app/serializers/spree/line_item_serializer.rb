module Spree
  class LineItemSerializer < ActiveModel::Serializer
    attributes :id, :variant_id, :quantity, :display_amount, :thumbnail_url, :large_image_url

    has_one :variant

    def display_amount
      object.display_amount.to_s
    end

    def thumbnail_url
      object.variant.display_image.attachment.url(:small, true)
    end

    def large_image_url
      object.variant.display_image.attachment.url(:large, true)
    end
  end
end
