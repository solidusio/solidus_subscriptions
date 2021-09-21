# frozen_string_literal: true

RSpec.describe SolidusSubscriptions::ProcessSubscriptionJob do
  it 'calls the configured processor class' do
    processor_class = class_spy(SolidusSubscriptions::Processor)
    stub_config(processor_class: processor_class)
    processor = instance_spy(SolidusSubscriptions::Processor)
    allow(processor_class).to receive(:new).and_return(processor)
    subscription = build_stubbed(:subscription)

    described_class.perform_now(subscription)

    expect(processor).to have_received(:call).with(subscription)
  end
end
