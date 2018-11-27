class AddEmailToSolidusSubscriptionsSubscriptions < ActiveRecord::Migration[5.1]
  def change
    add_column :solidus_subscriptions_subscriptions, :email, :string
  end
end
