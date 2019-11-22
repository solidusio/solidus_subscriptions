require 'spec_helper'

RSpec.describe SolidusSubscriptions::SuccessDispatcher do
  let(:dispatcher) { described_class.new(installments) }
  let(:installments) { create_list(:installment, 1) }

  describe 'initialization' do
    subject { dispatcher }
    it { is_expected.to be_a described_class }
  end

  describe '#dispatch' do
    subject { dispatcher.dispatch }

    it 'marks all the installments out of stock' do
      expect(installments).to all receive(:success!).once
      subject
    end

    it 'logs the failure' do
      expect(dispatcher).to receive(:notify).once
      subject
    end
  end
end
