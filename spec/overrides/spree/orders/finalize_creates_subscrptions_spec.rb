require 'spec_helper'

RSpec.describe Spree::Orders::FinalizeCreatesSubscriptions do
  describe '#finalize!' do
    subject { order.finalize! }

    let(:order) { create :order, :with_subscription_line_items }
    let(:subscription_line_item) { order.subscription_line_items.last }
    let(:expected_actionable_date) { (DateTime.current + subscription_line_item.interval).beginning_of_minute }

    around { |e| Timecop.freeze { e.run } }

    it 'creates new subscriptions' do
      expect { subject }.
        to change { SolidusSubscriptions::Subscription.count }.
        by(order.subscription_line_items.count)
    end

    it 'creates a subscription with the correct values' do
      subject
      subscription = SolidusSubscriptions::Subscription.last

      expect(subscription).to have_attributes(
        user_id: order.user_id,
        actionable_date: expected_actionable_date,
        line_items: [subscription_line_item]
      )
    end
  end
end
