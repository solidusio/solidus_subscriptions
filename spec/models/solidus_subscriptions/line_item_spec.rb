# frozen_string_literal: true

require "spec_helper"

RSpec.describe SolidusSubscriptions::LineItem, type: :model do
  it { is_expected.to validate_presence_of :subscribable_id }

  it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0) }
  it { is_expected.to validate_numericality_of(:interval_length).is_greater_than(0) }

  describe "#interval" do
    subject(:interval) { line_item.interval }

    let(:line_item) { create :subscription_line_item, :with_subscription }

    before do
      Timecop.freeze(Date.parse("2016-09-22"))
      line_item.subscription.update!(actionable_date: Date.current)
    end

    after { Timecop.return }

    it { is_expected.to be_a ActiveSupport::Duration }

    it "calculates the duration correctly" do
      expect(interval.from_now).to eq Date.parse("2016-10-22")
    end
  end

  describe "custom validation" do
    context "when subscribable is not true" do
      let(:subscribable) { create(:variant, subscribable: false) }
      let(:line_item) { build(:subscription_line_item, subscribable: subscribable) }

      it "adds an error to subscribable" do
        line_item.valid?
        expect(line_item.errors[:subscribable]).to include("The requested item cannot be subscribed")
      end
    end

    context "when subscribable is true" do
      let(:subscribable) { create(:variant, subscribable: true) }
      let(:line_item) { build(:subscription_line_item, subscribable: subscribable) }

      it "does not add an error to subscribable" do
        line_item.valid?
        expect(line_item.errors[:subscribable]).to be_empty
      end
    end
  end
end
