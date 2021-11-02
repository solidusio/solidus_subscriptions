class AddPausedToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_column :solidus_subscriptions_subscriptions, :paused, :boolean, default: false
  end
end
