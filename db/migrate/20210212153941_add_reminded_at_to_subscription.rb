class AddRemindedAtToSubscription < ActiveRecord::Migration[6.0]
  def change
    add_column :solidus_subscriptions_subscriptions, :reminded_at, :datetime
  end
end
