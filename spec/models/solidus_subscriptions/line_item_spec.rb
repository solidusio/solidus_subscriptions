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

  describe '#as_json' do
    subject { line_item.as_json }

    around { |e| Timecop.freeze { e.run } }
    let(:line_item) { create(:subscription_line_item, :with_subscription) }

    let(:expected_hash) do
      {
        "id" => line_item.id,
        "spree_line_item_id" => line_item.spree_line_item.id,
        "subscription_id" => line_item.subscription_id,
        "quantity" => line_item.quantity,
        "max_installments" => line_item.max_installments,
        "subscribable_id" => line_item.subscribable_id,
        "created_at" => line_item.created_at,
        "updated_at" => line_item.updated_at,
        "interval_units" => line_item.interval_units,
        "interval_length" => line_item.interval_length
      }
    end

    it 'includes the attribute values' do
      expect(subject).to match a_hash_including(expected_hash)
    end

    it 'includes the dummy lineitem' do
      expect(subject['dummy_line_item']).to be_a Spree::LineItem
    end
  end

  describe '#dummy_line_item' do
    subject { line_item.dummy_line_item }

    let(:line_item) { create(:subscription_line_item, :with_subscription) }

    it { is_expected.to be_a Spree::LineItem }
    it { is_expected.to be_frozen }

    it 'has the correct variant' do
      expect(subject.variant_id).to eq line_item.subscribable_id
    end
  end
end
