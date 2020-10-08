class AddGuestTokenToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :solidus_subscriptions_subscriptions, :guest_token, :string
    add_index :solidus_subscriptions_subscriptions, :guest_token, unique: true
  end
end
