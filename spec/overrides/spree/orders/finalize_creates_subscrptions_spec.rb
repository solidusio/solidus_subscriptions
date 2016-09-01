require 'rails_helper'

RSpec.describe Spree::Orders::FinalizeCreatesSubscriptions do
  describe '#finalize!' do
    subject { order.finalize! }
    let(:order) { create :order, :with_subscription_line_items }

    it 'creates new subscriptions' do
      expect { subject }.
        to change { SolidusSubscriptions::Subscription.count }.
        by(order.subscription_line_items.count)
    end
  end
end
