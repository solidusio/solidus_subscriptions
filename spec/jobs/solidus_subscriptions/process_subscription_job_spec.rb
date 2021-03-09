# frozen_string_literal: true

RSpec.describe SolidusSubscriptions::ProcessSubscriptionJob do
  context 'when clear_past_installments is enabled' do
    it 'voids the actionable date of the unfulfilled installments' do
      stub_config(clear_past_installments: true)
      subscription = create(:subscription)
      unfulfilled_installment =  create(:installment, :failed, subscription: subscription)

      described_class.perform_now(subscription)

      expect(unfulfilled_installment.reload.actionable_date).to eq(nil)
    end
  end

  context 'when the subscription is actionable' do
    it 'resets the successive_skip_count' do
      subscription = create(:subscription, :actionable, successive_skip_count: 3)

      described_class.perform_now(subscription)

      expect(subscription.reload.successive_skip_count).to eq(0)
    end

    it 'creates a new installment' do
      subscription = create(:subscription, :actionable)

      described_class.perform_now(subscription)

      expect(subscription.installments.count).to eq(1)
    end

    it 'advances the actionable date' do
      subscription = create(:subscription, :actionable)
      subscription.update_columns(interval_length: 1, interval_units: 'week')
      old_actionable_date = subscription.reload.actionable_date

      described_class.perform_now(subscription)

      expect(subscription.reload.actionable_date.to_date).to eq((old_actionable_date + 1.week).to_date)
    end
  end

  context 'when the subscription is pending cancellation' do
    it 'cancels the subscription' do
      subscription = create(
        :subscription,
        :actionable,
        :pending_cancellation,
      )
      described_class.perform_now(subscription)

      expect(subscription.reload.state).to eq('canceled')
    end
  end

  context 'when the subscription is pending of deactivation' do
    it 'deactivates the subscription' do
      subscription = create(
        :subscription,
        :actionable,
        interval_units: 'week',
        interval_length: 2,
        end_date: 3.days.from_now,
      )
      described_class.perform_now(subscription)

      expect(subscription.reload.state).to eq('inactive')
    end
  end

  it 'schedules all the subscription actionable installments for processing' do
    subscription = create(:subscription, :actionable)
    unfulfilled_installment = create(:installment, :failed, subscription: subscription)

    described_class.perform_now(subscription)

    new_installment = subscription.reload.installments.last
    [unfulfilled_installment, new_installment].each do |installment|
      expect(SolidusSubscriptions::ProcessInstallmentJob).to have_been_enqueued.with(installment)
    end
  end
end
