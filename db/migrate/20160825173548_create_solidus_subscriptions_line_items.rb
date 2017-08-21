class CreateSolidusSubscriptionsLineItems < SolidusSupport::Migration[4.2]
  def change
    create_table :solidus_subscriptions_line_items do |t|
      t.references :spree_line_item, index: true, foreign_key: true, null: false
      t.references :subscription, index: true
      t.integer :quantity, null: false
      t.integer :interval, null: false
      t.integer :installments
      t.integer :subscribable_id, index: true, null: false

      t.timestamps null: false
    end

    add_index :solidus_subscriptions_line_items, :subscription_id, name: :index_line_items_on_subscription_id
    add_foreign_key :solidus_subscriptions_line_items, :solidus_subscriptions_subscriptions, column: :subscription_id
  end
end
