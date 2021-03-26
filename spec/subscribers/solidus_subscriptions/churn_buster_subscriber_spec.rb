# frozen_string_literal: true

RSpec.describe SolidusSubscriptions::ChurnBusterSubscriber do
  describe '#report_subscription_cancellation' do
    it 'reports the cancellation to Churn Buster' do
      churn_buster = instance_spy(SolidusSubscriptions::ChurnBuster::Client)
      allow(SolidusSubscriptions).to receive(:churn_buster).and_return(churn_buster)

      subscription = create(:subscription)
      Spree::Event.fire('solidus_subscriptions.subscription_canceled', subscription: subscription)

      expect(churn_buster).to have_received(:report_subscription_cancellation).with(subscription)
    end
  end

  describe '#report_subscription_ending' do
    it 'reports the cancellation to Churn Buster' do
      churn_buster = instance_spy(SolidusSubscriptions::ChurnBuster::Client)
      allow(SolidusSubscriptions).to receive(:churn_buster).and_return(churn_buster)

      subscription = create(:subscription)
      Spree::Event.fire('solidus_subscriptions.subscription_ended', subscription: subscription)

      expect(churn_buster).to have_received(:report_subscription_cancellation).with(subscription)
    end
  end

  describe '#report_payment_success' do
    it 'reports the success to Churn Buster' do
      churn_buster = instance_spy(SolidusSubscriptions::ChurnBuster::Client)
      allow(SolidusSubscriptions).to receive(:churn_buster).and_return(churn_buster)

      order = build_stubbed(:order)
      installment = build_stubbed(:installment)
      Spree::Event.fire(
        'solidus_subscriptions.installment_succeeded',
        installment: installment,
        order: order,
      )

      expect(churn_buster).to have_received(:report_successful_payment).with(order)
    end
  end

  describe '#report_payment_failure' do
    it 'reports the failure to Churn Buster' do
      churn_buster = instance_spy(SolidusSubscriptions::ChurnBuster::Client)
      allow(SolidusSubscriptions).to receive(:churn_buster).and_return(churn_buster)

      order = build_stubbed(:order)
      installment = build_stubbed(:installment)
      Spree::Event.fire(
        'solidus_subscriptions.installment_failed_payment',
        installment: installment,
        order: order,
      )

      expect(churn_buster).to have_received(:report_failed_payment).with(order)
    end
  end

  describe '#report_payment_method_change' do
    it 'reports the payment method change to Churn Buster' do
      churn_buster = instance_spy(SolidusSubscriptions::ChurnBuster::Client)
      allow(SolidusSubscriptions).to receive(:churn_buster).and_return(churn_buster)

      subscription = create(:subscription)
      Spree::Event.fire(
        'solidus_subscriptions.subscription_payment_method_changed',
        subscription: subscription,
      )

      expect(churn_buster).to have_received(:report_payment_method_change).with(subscription)
    end
  end
end
