require 'spec_helper'

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
      if Spree.solidus_gem_version > Gem::Version.new('2.10')
        skip 'Orders in cart state cannot be canceled starting from Solidus 2.11'
      end
      expect { subject }.to change(order, :state).to 'canceled'
    end
  end
end
