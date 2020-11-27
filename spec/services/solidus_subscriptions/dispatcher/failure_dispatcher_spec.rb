RSpec.describe SolidusSubscriptions::Dispatcher::FailureDispatcher do
  describe '#dispatch' do
    it 'marks all the installments as failed' do
      installments = Array.new(2) { instance_spy(SolidusSubscriptions::Installment) }
      order = create(:order_with_line_items)

      dispatcher = described_class.new(installments, order)
      dispatcher.dispatch

      expect(installments).to all(have_received(:failed!).with(order).once)
    end

    it 'cancels the order' do
      if Spree.solidus_gem_version > Gem::Version.new('2.10')
        skip 'Orders in `cart` state cannot be canceled starting from Solidus 2.11.'
      end

      installments = Array.new(2) { instance_spy(SolidusSubscriptions::Installment) }
      order = create(:order_with_line_items)

      dispatcher = described_class.new(installments, order)
      dispatcher.dispatch

      expect(order.state).to eq('canceled')
    end
  end
end
