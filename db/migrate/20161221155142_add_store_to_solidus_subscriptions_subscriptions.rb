class AddStoreToSolidusSubscriptionsSubscriptions < SolidusSupport::Migration[4.2]
  def change
    add_reference :solidus_subscriptions_subscriptions, :store, index: true
    add_foreign_key :solidus_subscriptions_subscriptions, :spree_stores, column: :store_id
  end
end
