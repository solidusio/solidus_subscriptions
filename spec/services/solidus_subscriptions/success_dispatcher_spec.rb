RSpec.describe SolidusSubscriptions::SuccessDispatcher do
  describe '#dispatch' do
    it 'marks all the installments as success' do
      installments = Array.new(2) { instance_spy(SolidusSubscriptions::Installment) }
      order = create(:order_with_line_items)

      dispatcher = described_class.new(installments, order)
      dispatcher.dispatch

      expect(installments).to all(have_received(:success!).with(order).once)
    end
  end
end
