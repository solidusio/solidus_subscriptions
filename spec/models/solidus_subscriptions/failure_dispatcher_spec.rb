require 'rails_helper'

RSpec.describe SolidusSubscriptions::FailureDispatcher do
  let(:dispatcher) { described_class.new(installments) }
  let(:installments) { build_list(:installment, 2) }

  describe '#dispatch' do
    subject { dispatcher.dispatch }

    it 'marks all the installments out of stock' do
      expect(installments).to all receive(:failed).once
      subject
    end

    it 'logs the failure' do
      expect(dispatcher).to receive(:notify).once
      subject
    end
  end
end
