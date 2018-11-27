class AddBillingAddressIdToSolidusSubscriptionsSubscriptions < ActiveRecord::Migration[5.1]
  def change
    add_reference :solidus_subscriptions_subscriptions, :billing_address
    add_index :solidus_subscriptions_subscriptions, :billing_address_id, name: :index_subscription_billing_address_id
    add_foreign_key :solidus_subscriptions_subscriptions, :spree_addresses, column: :billing_address_id
  end
end
