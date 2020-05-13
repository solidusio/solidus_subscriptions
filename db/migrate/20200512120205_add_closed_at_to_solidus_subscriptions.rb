class AddClosedAtToSolidusSubscriptions < ActiveRecord::Migration[6.0]
  def change
    add_column :solidus_subscriptions_subscriptions, :closed_at, :datetime
  end
end
