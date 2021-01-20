RSpec.describe SolidusSubscriptions::Dispatcher::FailureDispatcher do
  describe '#dispatch' do
    it 'marks the installment as failed' do
      installment = instance_spy(SolidusSubscriptions::Installment)
      order = create(:order_with_line_items)

      dispatcher = described_class.new(installment, order)
      dispatcher.dispatch

      expect(installment).to have_received(:failed!).with(order)
    end

    it 'cancels the order' do
      if Spree.solidus_gem_version > Gem::Version.new('2.10')
        skip 'Orders in `cart` state cannot be canceled starting from Solidus 2.11.'
      end

      installment = instance_spy(SolidusSubscriptions::Installment)
      order = create(:order_with_line_items)

      dispatcher = described_class.new(installment, order)
      dispatcher.dispatch

      expect(order.state).to eq('canceled')
    end
  end
end
