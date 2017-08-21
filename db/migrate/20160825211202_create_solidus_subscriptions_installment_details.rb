class CreateSolidusSubscriptionsInstallmentDetails < SolidusSupport::Migration[4.2]
  def change
    create_table :solidus_subscriptions_installment_details do |t|
      t.references :installment, null: false
      t.string :state, null: false

      t.timestamps null: false
    end

    add_index(
      :solidus_subscriptions_installment_details,
      :installment_id,
      name: :index_installment_details_on_installment_id
    )

    add_foreign_key(
      :solidus_subscriptions_installment_details,
      :solidus_subscriptions_installments,
      column: :installment_id
    )
  end
end
