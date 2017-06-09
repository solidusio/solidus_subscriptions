class RemoveStateFromSolidusSusbscriptionsInstallmentDetails < SolidusSupport::Migration[4.2]
  def change
    remove_column :solidus_subscriptions_installment_details, :state, :string
  end
end
