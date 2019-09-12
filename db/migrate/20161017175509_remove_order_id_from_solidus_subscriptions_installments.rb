class RemoveOrderIdFromSolidusSubscriptionsInstallments < SolidusSupport::Migration[4.2]
  def change
    remove_column :solidus_subscriptions_installments, :order_id, :integer
  end
end
