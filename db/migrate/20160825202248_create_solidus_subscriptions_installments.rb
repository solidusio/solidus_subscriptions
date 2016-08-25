class CreateSolidusSubscriptionsInstallments < ActiveRecord::Migration
  def change
    create_table :solidus_subscriptions_installments do |t|
      t.references :subscription, index: true, foreign_key: true, null: false
      t.references :order, index: true, foreign_key: true
      t.date :actionable_date

      t.timestamps null: false
    end
  end
end
