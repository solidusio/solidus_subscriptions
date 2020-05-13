class AddOriginalOrderIdToSolidusSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :solidus_subscriptions_subscriptions, :original_order_id, :bigint
  end
end
