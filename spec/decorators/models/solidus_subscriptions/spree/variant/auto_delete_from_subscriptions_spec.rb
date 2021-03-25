# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusSubscriptions::Spree::Variant::AutoDeleteFromSubscriptions, type: :model do
  subject { create(:variant, subscribable: true) }

  describe '.discard' do
    it 'deletes itself from subscriptions' do
      subscription = create(:subscription)
      create(:subscription_line_item, subscription: subscription, subscribable: subject)

      expect { subject.discard }.to change { SolidusSubscriptions::LineItem.count }.by(-1)
    end
  end

  describe '.destroy' do
    it 'deletes itself from subscriptions' do
      subscription = create(:subscription)
      create(:subscription_line_item, subscription: subscription, subscribable: subject)

      expect { subject.destroy }.to change { SolidusSubscriptions::LineItem.count }.by(-1)
    end
  end
end
