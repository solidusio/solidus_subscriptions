require 'rails_helper'

RSpec.describe SolidusSubscriptions::FailureDispatcher do
  let(:dispatcher) { described_class.new(installments, order) }
  let(:installments) { build_list(:installment, 2) }

  let(:order) { create :order_with_line_items }

  describe '#dispatch' do
    subject { dispatcher.dispatch }

    it 'marks all the installments out of stock' do
      expect(installments).to all receive(:failed!).once
      subject
    end

    it 'logs the failure' do
      expect(dispatcher).to receive(:notify).once
      subject
    end

    it 'cancels the order' do
      expect { subject }.to change { order.state }.to 'canceled'
    end

    it 'sets completed_at' do
      subject
      expect(order.reload.completed_at).to be_present
    end

    it 'sets frontend_viewable to false' do
      subject
      expect(order.frontend_viewable).to be_falsey
    end
  end
end
