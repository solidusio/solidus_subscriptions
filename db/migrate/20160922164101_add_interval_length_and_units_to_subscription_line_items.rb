class AddIntervalLengthAndUnitsToSubscriptionLineItems < SolidusSupport::Migration[4.2]
  def change
    add_column :solidus_subscriptions_line_items, :interval_units, :integer
    add_column :solidus_subscriptions_line_items, :interval_length, :integer

    remove_column :solidus_subscriptions_line_items, :interval
  end
end
