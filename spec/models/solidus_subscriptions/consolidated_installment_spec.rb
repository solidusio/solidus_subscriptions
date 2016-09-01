require 'rails_helper'

RSpec.describe SolidusSubscriptions::ConsolidatedInstallment do
  describe '#process' do
    subject { described_class.new(installments).process }
    let(:installments) { build_stubbed_list(:installment, 1) }

    it { is_expected.to be_a Spree::Order }
  end
end
