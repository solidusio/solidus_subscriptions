# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusSubscriptions::Spree::Order::FinalizeCreatesSubscriptions do
  describe '#finalize!' do
    subject(:finalize) { order.finalize! }

    let(:order) { create :order, :with_subscription_line_items }
    let(:subscription_line_item) { order.subscription_line_items.last }
    let(:expected_actionable_date) { Time.zone.today + subscription_line_item.subscription.interval }

    around { |e| Timecop.freeze { e.run } }

    it 'creates new subscriptions' do
      expect { finalize }.
        to change { SolidusSubscriptions::Subscription.count }.
        by(order.subscription_line_items.count)
    end

    it 'creates a subscription with the correct values' do
      finalize
      subscription = SolidusSubscriptions::Subscription.last

      expect(subscription).to have_attributes(
        user_id: order.user_id,
        actionable_date: expected_actionable_date,
        line_items: [subscription_line_item]
      )
    end
  end
end
