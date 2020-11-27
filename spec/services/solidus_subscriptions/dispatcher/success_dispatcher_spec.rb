RSpec.describe SolidusSubscriptions::Dispatcher::SuccessDispatcher do
  describe '#dispatch' do
    it 'marks all the installments as success' do
      installments = Array.new(2) { instance_spy(SolidusSubscriptions::Installment) }
      order = create(:order_with_line_items)

      dispatcher = described_class.new(installments, order)
      dispatcher.dispatch

      expect(installments).to all(have_received(:success!).with(order).once)
    end

    it 'fires an installments_succeeded event' do
      stub_const('Spree::Event', class_spy(Spree::Event))
      installments = Array.new(2) { instance_spy(SolidusSubscriptions::Installment) }
      order = create(:order_with_line_items)

      dispatcher = described_class.new(installments, order)
      dispatcher.dispatch

      expect(Spree::Event).to have_received(:fire).with(
        'solidus_subscriptions.installments_succeeded',
        installments: installments,
        order: order,
      )
    end
  end
end
