class ChangeSubscriptionLineItemsInstallmentsToMaxInstallments < SolidusSupport::Migration[4.2]
  def change
    rename_column :solidus_subscriptions_line_items, :installments, :max_installments
  end
end
