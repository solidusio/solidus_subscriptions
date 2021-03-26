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
      expect { described_class.perform_now(nil) }.not_to raise_error(StandardError)
    end

    it 'runs proc when a proc is configured' do
      stub_config(processing_error_handler: proc { |e| raise e } )

      expect { described_class.perform_now(nil) }.to raise_error(StandardError)
    end
  end
end
