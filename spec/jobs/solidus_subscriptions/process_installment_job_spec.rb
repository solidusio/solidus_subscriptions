# frozen_string_literal: true

RSpec.describe SolidusSubscriptions::ProcessInstallmentJob do
  it 'processes checkout for the installment' do
    installment = build_stubbed(:installment)
    checkout = instance_spy(SolidusSubscriptions::Checkout)
    allow(SolidusSubscriptions::Checkout).to receive(:new).with(installment).and_return(checkout)

    described_class.perform_now(installment)

    expect(checkout).to have_received(:process)
  end

  context 'when handling #perform errors' do
    it 'swallows error when a proc is not configured' do
      checkout = instance_double(SolidusSubscriptions::Checkout).tap do |c|
        allow(c).to receive(:process).and_raise('test error')
      end
      allow(SolidusSubscriptions::Checkout).to receive(:new).and_return(checkout)

      expect {
        described_class.perform_now(build_stubbed(:installment))
      }.not_to raise_error
    end

    it 'runs proc when a proc is configured' do
      stub_config(processing_error_handler: proc { |e| raise e } )
      checkout = instance_double(SolidusSubscriptions::Checkout).tap do |c|
        allow(c).to receive(:process).and_raise('test error')
      end
      allow(SolidusSubscriptions::Checkout).to receive(:new).and_return(checkout)

      expect {
        described_class.perform_now(build_stubbed(:installment))
      }.to raise_error(/test error/)
    end
  end
end
