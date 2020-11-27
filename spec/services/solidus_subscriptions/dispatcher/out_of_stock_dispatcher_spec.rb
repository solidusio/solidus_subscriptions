RSpec.describe SolidusSubscriptions::Dispatcher::OutOfStockDispatcher do
  describe '#dispatch' do
    it 'marks all the installments as out of stock' do
      installments = Array.new(2) { instance_spy(SolidusSubscriptions::Installment) }

      dispatcher = described_class.new(installments)
      dispatcher.dispatch

      expect(installments).to all(have_received(:out_of_stock).once)
    end
  end
end
