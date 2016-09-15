require 'rails_helper'

RSpec.describe SolidusSubscriptions::Installment, type: :model do
  it { is_expected.to have_many :details }
  it { is_expected.to belong_to :order }
  it { is_expected.to belong_to :subscription }

  it { is_expected.to validate_presence_of :subscription }

  let(:installment) { create :installment }

  describe '#line_item_builder' do
    subject { installment.line_item_builder }

    let(:line_item) { installment.subscription.line_item }

    it { is_expected.to be_a SolidusSubscriptions::LineItemBuilder }
    it { is_expected.to have_attributes(subscription_line_item: line_item) }
  end

  describe '#out_of_stock' do
    subject { installment.out_of_stock }

    let(:expected_date) do
      Date.today + SolidusSubscriptions::Config.reprocessing_interval
    end

    it { is_expected.to be_a SolidusSubscriptions::InstallmentDetail }
    it { is_expected.to_not be_successful }
    it 'has the correct message' do
      expect(subject).to have_attributes(
        message: I18n.t('solidus_subscriptions.installment_details.out_of_stock')
      )
    end

    it 'advances the installment actionable_date' do
      subject
      actionable_date = installment.reload.actionable_date
      expect(actionable_date).to eq expected_date
    end
  end
end
