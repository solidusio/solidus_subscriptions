# frozen_string_literal: true

RSpec.describe SolidusSubscriptions::CreateSubscriptionJob do
  describe '#perform' do
    it 'creates new subscriptions for an order' do
      order = create(:order, :with_subscription_line_items)
      subscription_line_item = order.subscription_line_items.last

      described_class.perform_now(order)

      expect(SolidusSubscriptions::Subscription.count).to eq(order.subscription_line_items.count)
      subscription = SolidusSubscriptions::Subscription.last
      expect(subscription).to have_attributes(
        user_id: order.user_id,
        actionable_date: Time.zone.today + subscription.interval,
        line_items: [subscription_line_item]
      )
    end
  end
end
