require 'rails_helper'

RSpec.describe SolidusSubscriptions::Installment, type: :model do
  it { is_expected.to have_many :details }
  it { is_expected.to belong_to :order }
  it { is_expected.to belong_to :subscription }

  it { is_expected.to validate_presence_of :subscription }

  let(:installment) { build_stubbed :installment }

  describe '#line_item_builder' do
    subject { installment.line_item_builder }

    let(:line_item) { installment.subscription.line_item }

    it { is_expected.to be_a SolidusSubscriptions::LineItemBuilder }
    it { is_expected.to have_attributes(subscription_line_item: line_item) }
  end
end
