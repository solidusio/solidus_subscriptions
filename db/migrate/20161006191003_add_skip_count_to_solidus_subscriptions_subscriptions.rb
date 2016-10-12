class AddSkipCountToSolidusSubscriptionsSubscriptions < ActiveRecord::Migration
  def change
    add_column :solidus_subscriptions_subscriptions, :skip_count, :integer, default: 0, null: false
  end
end
