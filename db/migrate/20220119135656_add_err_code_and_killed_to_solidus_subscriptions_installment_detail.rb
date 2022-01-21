class AddErrCodeAndKilledToSolidusSubscriptionsInstallmentDetail < ActiveRecord::Migration[6.0]
  def change
    add_column :solidus_subscriptions_installment_details, :err_code, :string
  end
end
