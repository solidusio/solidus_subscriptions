require 'spec_helper'

RSpec.describe SolidusSubscriptions::SubscriptionGenerator do
  describe '.activate' do
    subject { described_class.activate(subscription_line_items) }

    let(:subscription_line_item) { subscription_line_items.first }
    let(:user) { subscription_line_items.first.order.user }
    let(:store) { subscription_line_items.first.order.store }

    it { is_expected.to be_a SolidusSubscriptions::Subscription }

    let(:subscription_line_items) { build_list :subscription_line_item, 2 }

    it 'creates the correct number of subscriptions' do
      expect { subject }.
        to change { SolidusSubscriptions::Subscription.count }.
        by(1)
    end

    it 'creates subscriptions with the correct attributes', :aggregate_failures do
      expect(subject).to have_attributes(
        user: user,
        shipping_address: subscription_line_item.spree_line_item.order.ship_address,
        interval_length: subscription_line_item.interval_length,
        interval_units: subscription_line_item.interval_units,
        end_date: subscription_line_item.end_date,
        store: store
      )

      expect(subject.line_items).to match_array subscription_line_items
    end
  end

  describe '.group' do
    subject { described_class.group(subscription_line_items) }

    let(:monthly_subscriptions) { build_stubbed_list :subscription_line_item, 2 }
    let(:bimonthly_subscriptions) { build_stubbed_list :subscription_line_item, 2, interval_length: 2 }
    let(:weekly_subscriptions) { build_stubbed_list :subscription_line_item, 2, interval_units: :week }
    let(:expiring_subscriptions) { build_stubbed_list :subscription_line_item, 2, end_date: DateTime.current.tomorrow }

    let(:subscription_line_items) { monthly_subscriptions + bimonthly_subscriptions + weekly_subscriptions + expiring_subscriptions }

    it { is_expected.to be_a Array }
    it { is_expected.to include monthly_subscriptions }
    it { is_expected.to include bimonthly_subscriptions }
    it { is_expected.to include weekly_subscriptions }
    it { is_expected.to include expiring_subscriptions }
  end
end
