class AllowSpreeLineItemIdToBeNull < ActiveRecord::Migration
  def change
    change_column_null :solidus_subscriptions_line_items, :spree_line_item_id, true
  end
end
