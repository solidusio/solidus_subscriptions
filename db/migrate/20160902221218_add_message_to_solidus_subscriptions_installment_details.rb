class AddMessageToSolidusSubscriptionsInstallmentDetails < SolidusSupport::Migration[4.2]
  def change
    add_column :solidus_subscriptions_installment_details, :message, :string
  end
end
