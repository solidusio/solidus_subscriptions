require 'rails_helper'

RSpec.describe SolidusSubscriptions::ConsolidatedInstallment do
  let(:consolidated_installment) { described_class.new(installments) }
  let(:installments) { create_list(:installment, 2) }

  describe '#process', :checkout do
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

    it 'has a shipment' do
      expect(order.shipments).to be_present
    end

    it 'has a payment' do
      expect(order.payments.valid).to be_present
    end

    it 'has the correct totals' do
      expect(order).to have_attributes(
        total: 29.99,
        shipment_total: 10
      )
    end

    it { is_expected.to be_complete }
  end

  describe '#order' do
    subject { consolidated_installment.order }
    let(:user) { installments.first.subscription.user }
    let(:root_order) { installments.first.subscription.root_order }

    it { is_expected.to be_a Spree::Order }

    it 'has the correct attributes' do
      expect(subject).to have_attributes(
        user: user,
        email: user.email,
        store: root_order.store
      )
    end

    it 'is the same instance any time its called' do
      order = consolidated_installment.order
      expect(subject).to equal order
    end
  end
end
