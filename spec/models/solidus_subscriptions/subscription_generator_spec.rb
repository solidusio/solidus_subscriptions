require 'rails_helper'

RSpec.describe SolidusSubscriptions::SubscriptionGenerator do
  describe '.activate' do
    subject { described_class.activate(subscription_line_items) }

    let(:subscription_line_items) { build_list :subscription_line_item, 1 }
    let(:subscription_line_item) { subscription_line_items.first }
    let(:user) { subscription_line_items.first.order.user }

    it { is_expected.to be_a Array }

    it 'creates the correct number of subscritpions' do
      expect { subject }.
        to change { SolidusSubscriptions::Subscription.count }.
        by(subscription_line_items.count)
    end

    it 'creates subscriptions with the correct attributes' do
      subscription = subject.first
      expect(subscription).to have_attributes(
        user: user,
        line_item: subscription_line_item
      )
    end
  end
end
