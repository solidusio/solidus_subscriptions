class AddPaymentMethodToSubscriptions < ActiveRecord::Migration[5.2]
  def change
    add_reference(
      :solidus_subscriptions_subscriptions,
      :payment_method,
      type: :integer,
      index: { name: :index_subscription_payment_method_id },
      foreign_key: { to_table: :spree_payment_methods }
    )
  end
end
