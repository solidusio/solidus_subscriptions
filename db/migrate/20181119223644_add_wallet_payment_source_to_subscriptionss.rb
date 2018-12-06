class AddWalletPaymentSourceToSubscriptionss < ActiveRecord::Migration[5.1]
  def change
    add_reference :solidus_subscriptions_subscriptions, :spree_wallet_payment_source, foreign_key: true, index: { name: :index_subscriptions_on_spree_wallet_payment_source_id }
  end
end
