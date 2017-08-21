class AllowSpreeLineItemIdToBeNull < SolidusSupport::Migration[4.2]
  def change
    change_column_null :solidus_subscriptions_line_items, :spree_line_item_id, true
  end
end
