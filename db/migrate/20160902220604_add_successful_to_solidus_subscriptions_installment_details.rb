class AddSuccessfulToSolidusSubscriptionsInstallmentDetails < ActiveRecord::Migration
  def change
    add_column :solidus_subscriptions_installment_details, :success, :boolean
  end
end
