# frozen_string_literal: true

RSpec.describe SolidusSubscriptions::ChurnBuster::Client, vcr: { cassette_name: 'churn_buster', record: :new_episodes } do
  describe '#report_failed_payment' do
    it 'reports the failed payment to Churn Buster' do
      client = described_class.new(
        account_id: 'test_account_id',
        api_key: 'test_api_key',
      )

      order = create(:order, subscription: create(:subscription))
      response = client.report_failed_payment(order)

      expect(response).to be_success
    end
  end

  describe '#report_successful_payment' do
    it 'reports the successful payment to Churn Buster' do
      client = described_class.new(
        account_id: 'test_account_id',
        api_key: 'test_api_key',
      )

      order = create(:order, subscription: create(:subscription))
      response = client.report_successful_payment(order)

      expect(response).to be_success
    end
  end

  describe '#report_subscription_cancellation' do
    it 'reports the failed payment to Churn Buster' do
      client = described_class.new(
        account_id: 'test_account_id',
        api_key: 'test_api_key',
      )

      subscription = create(:subscription)
      response = client.report_subscription_cancellation(subscription)

      expect(response).to be_success
    end
  end

  describe '#report_payment_method_change' do
    it 'reports the payment method change to Churn Buster' do
      client = described_class.new(
        account_id: 'test_account_id',
        api_key: 'test_api_key',
      )

      subscription = create(:subscription)
      response = client.report_payment_method_change(subscription)

      expect(response).to be_success
    end
  end
end
