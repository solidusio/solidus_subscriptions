require 'spec_helper'

RSpec.describe SolidusSubscriptions::InstallmentDetail, type: :model do
  it { is_expected.to belong_to :installment }
  it { is_expected.to belong_to :order }

  it { is_expected.to validate_presence_of :installment }

  describe '#failed?' do
    subject { build(:installment_detail, success: success).failed? }

    context 'the detail was successful' do
      let(:success) { true }
      it { is_expected.to be_falsy }
    end

    context 'the detail was not successfuly' do
      let(:success) { false }
      it { is_expected.to be_truthy }
    end
  end
end
