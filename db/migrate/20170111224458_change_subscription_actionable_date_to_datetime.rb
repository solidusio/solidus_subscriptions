class ChangeSubscriptionActionableDateToDatetime < ActiveRecord::Migration
  def change
    change_column :solidus_subscriptions_subscriptions, :actionable_date, :datetime
  end
end
