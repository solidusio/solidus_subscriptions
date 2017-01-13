class ChangeLineItemMaxInstallmentsToEndDate < ActiveRecord::Migration
  def change
    remove_column :solidus_subscriptions_line_items, :max_installments
    add_column :solidus_subscriptions_line_items, :end_date, :date
  end
end
