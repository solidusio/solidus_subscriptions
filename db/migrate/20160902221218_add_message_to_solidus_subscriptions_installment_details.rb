class AddMessageToSolidusSubscriptionsInstallmentDetails < ActiveRecord::Migration
  def change
    add_column :solidus_subscriptions_installment_details, :message, :string
  end
end
