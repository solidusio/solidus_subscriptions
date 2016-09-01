require 'rails_helper'

RSpec.describe SolidusSubscriptions::ConsolidatedInstallment do
  let(:consolidated_installment) { described_class.new(installments) }
  let(:installments) { create_list(:installment, 2) }

  describe '#process' do
    subject(:order) { consolidated_installment.process }

    let(:subscription_line_item) { installments.first.subscription.line_item }

    it { is_expected.to be_a Spree::Order }

    it 'has the correct number of line items' do
      count = order.line_items.length
      expect(count).to eq installments.count
    end

    it 'the line items have the correct values' do
      line_item = order.line_items.first
      expect(line_item).to have_attributes(
        quantity: subscription_line_item.quantity,
        variant_id: subscription_line_item.subscribable_id
      )
    end
  end

  describe '#order' do
    subject { consolidated_installment.order }

    it { is_expected.to be_a Spree::Order }

    it 'is the same instance any time its called' do
      order = consolidated_installment.order
      expect(subject).to equal order
    end
  end
end
