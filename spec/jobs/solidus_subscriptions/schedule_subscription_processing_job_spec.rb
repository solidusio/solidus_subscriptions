RSpec.describe SolidusSubscriptions::ScheduleSubscriptionProcessingJob do
  it 'calls the scheduler service' do
    scheduler = instance_spy(SolidusSubscriptions::Scheduler)
    allow(SolidusSubscriptions::Scheduler).to receive(:new).and_return(scheduler)

    described_class.perform_now

    expect(scheduler).to have_received(:call)
  end
end
