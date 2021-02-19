class AddCurrencyToSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :solidus_subscriptions_subscriptions, :currency, :string
  end
end
