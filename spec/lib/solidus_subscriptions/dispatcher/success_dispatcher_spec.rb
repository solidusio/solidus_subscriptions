# frozen_string_literal: true

RSpec.describe SolidusSubscriptions::Dispatcher::SuccessDispatcher do
  describe '#dispatch' do
    it 'marks the installment as success' do
      installment = instance_spy(SolidusSubscriptions::Installment)
      order = create(:order_with_line_items)

      dispatcher = described_class.new(installment, order)
      dispatcher.dispatch

      expect(installment).to have_received(:success!).with(order)
    end

    it 'fires an installments_succeeded event' do
      stub_const('Spree::Event', class_spy(Spree::Event))
      installment = instance_spy(SolidusSubscriptions::Installment)
      order = create(:order_with_line_items)

      dispatcher = described_class.new(installment, order)
      dispatcher.dispatch

      expect(Spree::Event).to have_received(:fire).with(
        'solidus_subscriptions.installment_succeeded',
        installment: installment,
        order: order,
      )
    end
  end
end
