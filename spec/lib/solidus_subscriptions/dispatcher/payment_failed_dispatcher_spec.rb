RSpec.describe SolidusSubscriptions::Dispatcher::PaymentFailedDispatcher do
  describe '#dispatch' do
    it 'marks the installment as payment_failed' do
      installment = instance_spy(SolidusSubscriptions::Installment)
      order = create(:order_with_line_items)

      dispatcher = described_class.new(installment, order)
      dispatcher.dispatch

      expect(installment).to have_received(:payment_failed!).with(order)
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

    it 'fires an installments_failed_payment event' do
      stub_const('Spree::Event', class_spy(Spree::Event))
      installment = instance_spy(SolidusSubscriptions::Installment)
      order = create(:order_with_line_items)

      dispatcher = described_class.new(installment, order)
      dispatcher.dispatch

      expect(Spree::Event).to have_received(:fire).with(
        'solidus_subscriptions.installment_failed_payment',
        installment: installment,
        order: order,
      )
    end
  end
end
