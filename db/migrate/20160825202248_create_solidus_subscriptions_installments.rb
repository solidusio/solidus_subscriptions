class CreateSolidusSubscriptionsInstallments < SolidusSupport::Migration[4.2]
  def change
    create_table :solidus_subscriptions_installments do |t|
      t.references :subscription, index: true, null: false
      t.references :order, index: true
      t.date :actionable_date

      t.timestamps null: false
    end

    add_foreign_key(
      :solidus_subscriptions_installments,
      :solidus_subscriptions_subscriptions,
      column: :subscription_id
    )

    add_foreign_key(
      :solidus_subscriptions_installments,
      :spree_orders,
      column: :order_id
    )
  end
end
