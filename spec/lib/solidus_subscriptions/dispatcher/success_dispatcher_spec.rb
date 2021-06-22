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
  end
end
