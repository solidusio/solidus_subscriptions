require 'rails_helper'

RSpec.describe SolidusSubscriptions::Processor, :checkout do
  let(:user) do
    ccs = build_list(:credit_card, 1, gateway_customer_profile_id: 'BGS-123', default: true)
    build :user, credit_cards: ccs
  end

  let!(:actionable_subscriptions) { create_list(:subscription, 2, :actionable, user: user) }
  let!(:future_subscriptions) { create_list(:subscription, 2, :not_actionable) }
  let!(:canceled_subscriptions) { create_list(:subscription, 2, :canceled) }
  let!(:inactive) { create_list(:subscription, 2, :inactive) }

  let!(:successful_installments) { create_list :installment, 2, :success }
  let!(:failed_installments) do
    create_list(
      :installment,
      2,
      :failed,
      subscription_traits: [{ user: user }]
    )
  end

  # all subscriptions and previously failed installments belong to the same user
  let(:expected_orders) { 1 }

  shared_examples 'a subscription order' do
    let(:order_variant_ids) { Spree::Order.last.variant_ids }
    let(:expected_ids) do
      subs_ids = actionable_subscriptions.map { |s| s.line_item.subscribable_id }
      inst_ids = failed_installments.map { |i| i.subscription.line_item.subscribable_id }

      subs_ids + inst_ids
    end

    it 'creates the correct number of orders' do
      expect { subject }.to change { Spree::Order.complete.count }.by expected_orders
    end

    it 'creates the correct order' do
      subject
      expect(order_variant_ids).to match_array expected_ids
    end
  end

  describe '.run' do
    subject { described_class.run }

    it_behaves_like 'a subscription order'
  end

  describe '#build_jobs' do
    subject { described_class.new([user]).build_jobs }
    it_behaves_like 'a subscription order'
  end
end
