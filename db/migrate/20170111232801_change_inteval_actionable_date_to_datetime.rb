class ChangeIntevalActionableDateToDatetime < SolidusSupport::Migration[4.2]
  def change
    change_column :solidus_subscriptions_installments, :actionable_date, :datetime
  end
end
