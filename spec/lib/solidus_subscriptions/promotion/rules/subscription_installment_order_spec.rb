# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusSubscriptions::Promotion::Rules::SubscriptionInstallmentOrder do
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

    context 'when the order fulfills a subscription installment' do
      let(:order) { create(:order, subscription_order: true) }

      it { is_expected.to be_truthy }
    end

    context 'when the order contains does not fulfill a subscription installment' do
      let(:order) { create(:order) }

      it { is_expected.to be_falsy }
    end
  end
end
