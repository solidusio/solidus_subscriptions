# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusSubscriptions::Promotion::Rules::SubscriptionCreationOrder do
  let(:rule) { described_class.new }

  describe '#applicable' do
    subject { rule.applicable? promotable }

    context 'when the promotable is a Spree::Order' do
      let(:promotable) { build_stubbed :order }

      it { is_expected.to be_truthy }
    end

    context 'when the promotable is not a Spree::Order' do
      let(:promotable) { build_stubbed :line_item }

      it { is_expected.to be_falsy }
    end
  end

  describe '#eligible?' do
    subject { rule.eligible? order }

    let(:order) { create(:order, line_items: line_items) }

    context 'when the order contains a line item with a subscription' do
      let(:line_items) { build_list(:line_item, 1, :with_subscription_line_items) }

      it { is_expected.to be_truthy }
    end

    context 'when the order does not contain a line item with a subscription' do
      let(:line_items) { build_list(:line_item, 1) }

      it { is_expected.to be_falsy }
    end
  end

  describe '#actionable?' do
    subject { rule.actionable? line_item }

    context 'when the line item has a subscription' do
      let(:line_item) { build_stubbed(:line_item, :with_subscription_line_items) }

      it { is_expected.to be_truthy }
    end

    context 'when the line item has no subscription' do
      let(:line_item) { build_stubbed :line_item }

      it { is_expected.to be_falsy }
    end
  end
end
