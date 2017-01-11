class ChangeIntevalActionableDateToDatetime < ActiveRecord::Migration
  def change
    change_column :solidus_subscriptions_installments, :actionable_date, :datetime
  end
end
