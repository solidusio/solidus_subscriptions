require 'rails_helper'

RSpec.describe SolidusSubscriptions::OutOfStockDispatcher do
  let(:dispatcher) { described_class.new(*installments) }
  let(:installments) { build_list(:installment, 2) }

  describe 'initialization' do
    subject { dispatcher }
    it { is_expected.to be_a described_class }
  end
end
