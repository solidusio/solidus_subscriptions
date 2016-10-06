class AddSuccessiveSkipCountToSolidusSubscriptionsSubscriptions < ActiveRecord::Migration
  def change
    add_column :solidus_subscriptions_subscriptions, :successive_skip_count, :integer, default: 0, null: false
  end
end
