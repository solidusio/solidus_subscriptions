class RemoveOrderIdFromSolidusSubscriptionsInstallments < SolidusSupport::Migration[4.2]
  def change
    remove_foreign_key :solidus_subscriptions_installments, column: :order_id
    remove_column :solidus_subscriptions_installments, :order_id, :integer
  end
end
