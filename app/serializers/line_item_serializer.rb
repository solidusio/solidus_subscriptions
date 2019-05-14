class LineItemSerializer < ActiveModel::Serializer
  attributes :id, :spree_line_item_id, :subscription_id, :quantity, :interval_units, :interval_length

  has_one :spree_line_item
end
