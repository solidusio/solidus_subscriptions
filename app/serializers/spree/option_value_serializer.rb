module Spree
  class OptionValueSerializer < ActiveModel::Serializer
    attributes :id, :name, :color, :presentation, :option_type_id

    has_one :option_type
  end
end
