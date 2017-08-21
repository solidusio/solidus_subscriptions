class CreateSolidusSubscriptionsInstallmentPromotions < ActiveRecord::Migration[4.2]
  def change
    create_table :solidus_subscriptions_installment_promotions do |t|
      t.references :installment, null: false
      t.references :promotion
      t.references :promotion_code

      t.timestamps null: false
    end

    add_foreign_key(
      :solidus_subscriptions_installment_promotions,
      :solidus_subscriptions_installments,
      column: :installment_id,
      name: :fk_installment_promotions_installment
    )

    add_foreign_key(
      :solidus_subscriptions_installment_promotions,
      :spree_promotions,
      column: :promotion_id,
      name: :fk_installment_promotions_promotion
    )

    add_foreign_key(
      :solidus_subscriptions_installment_promotions,
      :spree_promotion_codes,
      column: :promotion_code_id,
      name: :fk_installment_promotions_code
    )
  end
end
