class CreateSolidusSubscriptionsSubscriptionEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :solidus_subscriptions_subscription_events do |t|
      t.belongs_to(
        :subscription,
        null: false,
        foreign_key: { to_table: :solidus_subscriptions_subscriptions },
        index: { name: :idx_solidus_subscription_events_on_subscription_id },
        type: :integer,
      )
      t.string :event_type, null: false
      t.json :details, null: false

      t.timestamps
    end
  end
end
