require 'rails_helper'

RSpec.describe SolidusSubscriptions::PaymentFailedDispatcher do
  let(:dispatcher) { described_class.new(installments) }
  let(:installments) { build_list(:installment, 2) }

  describe 'initialization' do
    subject { dispatcher }
    it { is_expected.to be_a described_class }
  end

  describe '#dispatch' do
    subject { dispatcher.dispatch }

    it 'marks all the installments out of stock' do
      expect(installments).to all receive(:payment_failed!).once
      subject
    end

    it 'logs the failure' do
      expect(dispatcher).to receive(:notify).once
      subject
    end
  end
end
