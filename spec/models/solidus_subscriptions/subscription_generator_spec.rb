require 'rails_helper'

RSpec.describe SolidusSubscriptions::SubscriptionGenerator do
  describe '.activate' do
    subject { described_class.activate(subscription_line_items) }

    let(:subscription_line_items) { build_list :subscription_line_item, 1 }
    let(:subscription_line_item) { subscription_line_items.first }
    let(:user) { subscription_line_items.first.order.user }
    let(:store) { subscription_line_items.first.order.store }

    it { is_expected.to be_a SolidusSubscriptions::Subscription }

    it 'creates the correct number of subscritpions' do
      expect { subject }.
        to change { SolidusSubscriptions::Subscription.count }.
        by(subscription_line_items.count)
    end

    it 'creates subscriptions with the correct attributes' do
      expect(subject).to have_attributes(
        user: user,
        line_items: subscription_line_items,
        shipping_address: subscription_line_item.spree_line_item.order.ship_address,
        store: store
      )
    end
  end
end
