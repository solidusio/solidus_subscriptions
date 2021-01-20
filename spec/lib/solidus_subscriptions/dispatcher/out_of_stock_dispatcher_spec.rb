RSpec.describe SolidusSubscriptions::Dispatcher::OutOfStockDispatcher do
  describe '#dispatch' do
    it 'marks the installment as out of stock' do
      installment = instance_spy(SolidusSubscriptions::Installment)
      order = build_stubbed(:order)

      dispatcher = described_class.new(installment, order)
      dispatcher.dispatch

      expect(installment).to have_received(:out_of_stock)
    end
  end
end
