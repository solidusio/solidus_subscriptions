# frozen_string_literal: true

RSpec.describe SolidusSubscriptions::OrderSubscriber do
  describe 'on order completion' do
    it 'enqueues the CreateSubscriptionJob' do
      order = create(:order_ready_to_complete, :with_subscription_line_items)

      order.complete!

      expect(SolidusSubscriptions::CreateSubscriptionJob).to have_been_enqueued.with(order).once
    end
  end
end
