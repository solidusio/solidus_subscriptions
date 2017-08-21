class AddAddressIdToSolidusSubscriptionsSubscriptions < SolidusSupport::Migration[4.2]
  def change
    add_reference :solidus_subscriptions_subscriptions, :shipping_address
    add_index :solidus_subscriptions_subscriptions, :shipping_address_id, name: :index_subscription_shipping_address_id
    add_foreign_key :solidus_subscriptions_subscriptions, :spree_addresses, column: :shipping_address_id
  end
end
