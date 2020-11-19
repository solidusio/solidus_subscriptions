RSpec.describe SolidusSubscriptions::ProcessInstallmentJob do
  it 'processes checkout for the installment' do
    installment = build_stubbed(:installment)
    checkout = instance_spy(SolidusSubscriptions::Checkout)
    allow(SolidusSubscriptions::Checkout).to receive(:new).with(installment).and_return(checkout)

    described_class.perform_now(installment)

    expect(checkout).to have_received(:process)
  end
end
