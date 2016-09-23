require 'rails_helper'

RSpec.describe SolidusSubscriptions::LineItem, type: :model do
  it { is_expected.to belong_to :spree_line_item }
  it { is_expected.to belong_to :subscription }
  it { is_expected.to have_one :order }

  it { is_expected.to validate_presence_of :spree_line_item }
  it { is_expected.to validate_presence_of :subscribable_id }

  it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0) }
  it { is_expected.to validate_numericality_of(:interval_length).is_greater_than(0) }
  it { is_expected.to validate_numericality_of(:max_installments).is_greater_than(0) }
  it { is_expected.to validate_numericality_of(:max_installments).allow_nil }

  describe "#interval" do
    let(:line_item) { create :subscription_line_item, :with_subscription }
    before do
      Timecop.freeze(Date.parse("2016-09-22"))
      line_item.subscription.update!(actionable_date: Date.today)
    end
    after { Timecop.return }

    subject { line_item.interval }

    it { is_expected.to be_a ActiveSupport::Duration }
    it "calculates the duration correctly" do
      expect(subject.from_now).to eq Date.parse("2016-10-22")
    end
  end
end
