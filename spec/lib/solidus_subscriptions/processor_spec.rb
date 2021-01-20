RSpec.describe SolidusSubscriptions::Processor, :checkout do
  shared_examples 'processes the subscription' do
    it 'resets the successive_skip_count' do
      subscription
      subscription.update_columns(successive_skip_count: 3)

      described_class.run

      expect(subscription.reload.successive_skip_count).to eq(0)
    end

    context 'with clear_past_installments set to true' do
      it 'clears any past unfulfilled installments' do
        stub_config(clear_past_installments: true)
        subscription
        installment = create(:installment, :actionable, subscription: subscription)

        described_class.run

        expect(installment.reload.actionable_date).to eq(nil)
      end
    end

    context 'with clear_past_installments set to false' do
      it 'does not clear any past unfulfilled installments' do
        stub_config(clear_past_installments: false)
        subscription
        installment = create(:installment, :actionable, subscription: subscription)

        described_class.run

        expect(installment.reload.actionable_date).not_to be_nil
      end
    end

    it 'creates a new installment' do
      subscription

      described_class.run

      expect(subscription.installments.count).to eq(1)
    end

    it 'schedules the newly created installment for processing' do
      subscription

      described_class.run

      expect(SolidusSubscriptions::ProcessInstallmentJob).to have_been_enqueued
        .with(subscription.installments.last)
    end

    it 'schedules other actionable installments for processing' do
      actionable_installment = create(:installment, :actionable)

      described_class.run

      expect(SolidusSubscriptions::ProcessInstallmentJob).to have_been_enqueued
        .with(actionable_installment)
    end
  end

  shared_examples 'schedules the subscription for reprocessing' do
    it 'advances the actionable_date' do
      subscription
      subscription.update_columns(interval_length: 1, interval_units: 'week')
      old_actionable_date = subscription.actionable_date

      described_class.run

      expect(subscription.reload.actionable_date.to_date).to eq((old_actionable_date + 1.week).to_date)
    end
  end

  context 'with a regular subscription' do
    let(:subscription) { create(:subscription, :actionable) }

    include_examples 'processes the subscription'
    include_examples 'schedules the subscription for reprocessing'
  end

  context 'with a subscription that is pending deactivation' do
    let(:subscription) do
      create(
        :subscription,
        :actionable,
        interval_units: 'week',
        interval_length: 2,
        end_date: 3.days.from_now,
      )
    end

    include_examples 'processes the subscription'
    include_examples 'schedules the subscription for reprocessing'

    it 'deactivates the subscription' do
      subscription

      described_class.run

      expect(subscription.reload.state).to eq('inactive')
    end
  end

  context 'with a subscription that is pending cancellation' do
    let(:subscription) do
      create(
        :subscription,
        :actionable,
        :pending_cancellation,
      )
    end

    include_examples 'processes the subscription'

    it 'cancels the subscription' do
      subscription

      described_class.run

      expect(subscription.reload.state).to eq('canceled')
    end
  end
end
