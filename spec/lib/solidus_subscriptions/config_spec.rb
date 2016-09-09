require 'rails_helper'

RSpec.describe SolidusSubscriptions::Config do
  before { described_class.instance_variable_set('@gateway', nil) }
  after { described_class.instance_variable_set('@gateway', nil) }

  describe '.default_gateway' do
    subject(:gateway) { described_class.default_gateway }
    let(:bogus) { build_stubbed(:credit_card_payment_method) }

    context 'there is a gateway set' do
      before { described_class.instance_variable_set('@gateway', bogus) }
      it { is_expected.to eq bogus }
    end

    context 'there is no gateway set, but a gateway exists' do
      before { create(:credit_card_payment_method) }

      it 'gets the last credit card gateway' do
        expect(gateway).to eq(Spree::Gateway.last).and have_attributes(
          payment_source_class: Spree::CreditCard
        )
      end
    end

    context 'no gateway exists' do
      it 'raises a friendly error' do
        expect { subject }.to raise_error RuntimeError, /requires a Credit Card/
      end
    end
  end

  describe 'default_gateway=' do
    subject(:gateway) { described_class.default_gateway = value }
    let(:value) { 'test123' }

    it 'sets the correct instance variable' do
      subject
      expect(described_class.instance_variable_get('@gateway')).to eq value
    end
  end
end
