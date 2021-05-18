require 'spec_helper'

RSpec.describe SolidusSubscriptions::Reminder do
  let!(:subscription) {
    create(:subscription, :with_line_item, :with_shipping_address, :with_billing_address, :actionable,
           actionable_date: Time.zone.today + 3.days)
  }

  context 'when subscriptions are going to be renewed within the configured days' do

    before do
      SolidusSubscriptions.configuration.days_for_subscription_reminder = 3.days
    end

    it 'queues the reminder to be delivered' do
      expect {
        described_class.run
      }.to have_enqueued_job(SolidusSubscriptions::ProcessReminderJob)
    end
  end

  context 'when the configuration is set to 0' do

    before do
      SolidusSubscriptions.configuration.days_for_subscription_reminder = 0.days
    end

    it 'doesn\'t the reminder to be delivered' do
      expect {
        described_class.run
      }.not_to have_enqueued_job(SolidusSubscriptions::ProcessReminderJob)
    end
  end
end
