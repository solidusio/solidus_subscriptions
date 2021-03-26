# frozen_string_literal: true

RSpec.describe SolidusSubscriptions do
  describe '.churn_buster' do
    context 'when Churn Buster was configured' do
      it 'returns a Churn Buster client instance' do
        allow(described_class.configuration).to receive_messages(
          churn_buster?: true,
          churn_buster_account_id: 'account_id',
          churn_buster_api_key: 'api_key',
        )
        churn_buster = instance_double(SolidusSubscriptions::ChurnBuster::Client)
        allow(SolidusSubscriptions::ChurnBuster::Client).to receive(:new).with(
          account_id: 'account_id',
          api_key: 'api_key',
        ).and_return(churn_buster)

        expect(described_class.churn_buster).to eq(churn_buster)
      end
    end

    context 'when Churn Buster was not configured' do
      it 'returns nil' do
        allow(described_class.configuration).to receive_messages(churn_buster?: false)

        expect(described_class.churn_buster).to be_nil
      end
    end
  end
end
