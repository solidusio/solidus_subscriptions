require 'spec_helper'

RSpec.describe SolidusSubscriptions::Config do
  before { described_class.instance_variable_set('@gateway', nil) }
  after { described_class.instance_variable_set('@gateway', nil) }

  describe '.default_gateway' do
    let(:bogus) { build_stubbed(:credit_card_payment_method) }
    subject(:gateway) { described_class.default_gateway }

    before do
      described_class.default_gateway { bogus }
    end

    it { is_expected.to eq bogus }
  end
end
