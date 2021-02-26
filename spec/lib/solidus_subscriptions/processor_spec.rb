RSpec.describe SolidusSubscriptions::Processor do
  it 'schedules the processing of actionable subscriptions' do
    actionable_subscription = create(:subscription, :actionable)

    described_class.run

    expect(SolidusSubscriptions::ProcessSubscriptionJob).to have_been_enqueued
      .with(actionable_subscription)
  end

  it 'schedules the processing of non actionable subscriptions with actionable installments' do
    subscription_with_actionable_installment = create(
      :subscription,
      actionable_date: Time.zone.today + 7.days,
      installments: [create(:installment, :actionable)]
    )

    described_class.run

    expect(SolidusSubscriptions::ProcessSubscriptionJob).to have_been_enqueued
      .with(subscription_with_actionable_installment)
  end

  it 'does not schedule the processing of non actionable subscriptions' do
    non_actionable_subscription = create(:subscription, actionable_date: Time.zone.today + 14.days)

    described_class.run

    expect(SolidusSubscriptions::ProcessSubscriptionJob).not_to have_been_enqueued
      .with(non_actionable_subscription)
  end
end
