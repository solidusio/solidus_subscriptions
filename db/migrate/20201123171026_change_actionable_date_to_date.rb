class ChangeActionableDateToDate < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        change_column :solidus_subscriptions_subscriptions, :actionable_date, :date
        change_column :solidus_subscriptions_installments, :actionable_date, :date
      end

      dir.down do
        change_column :solidus_subscriptions_subscriptions, :actionable_date, :datetime
        change_column :solidus_subscriptions_installments, :actionable_date, :datetime
      end
    end
  end
end
