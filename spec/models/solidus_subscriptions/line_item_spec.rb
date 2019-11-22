require 'spec_helper'

RSpec.describe SolidusSubscriptions::LineItem, type: :model do
  it { is_expected.to belong_to :spree_line_item }
  it { is_expected.to belong_to :subscription }
  it { is_expected.to have_one :order }

  it { is_expected.to validate_presence_of :subscribable_id }

  it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0) }
  it { is_expected.to validate_numericality_of(:interval_length).is_greater_than(0) }

  describe "#interval" do
    let(:line_item) { create :subscription_line_item, :with_subscription }
    before do
      Timecop.freeze(Date.parse("2016-09-22"))
      line_item.subscription.update!(actionable_date: Date.current)
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
      hash = {
        "id" => line_item.id,
        "spree_line_item_id" => line_item.spree_line_item.id,
        "subscription_id" => line_item.subscription_id,
        "quantity" => line_item.quantity,
        "end_date" => line_item.end_date,
        "subscribable_id" => line_item.subscribable_id,
        "created_at" => line_item.created_at,
        "updated_at" => line_item.updated_at,
        "interval_units" => line_item.interval_units,
        "interval_length" => line_item.interval_length
      }
      Rails.gem_version >= Gem::Version.new('6.0.0') ? hash.as_json : hash
    end

    it 'includes the attribute values' do
      expect(subject).to match a_hash_including(expected_hash)
    end

    it 'includes the dummy lineitem' do
      expect(subject).to have_key('dummy_line_item')
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

    context 'with no spree line item' do
      let(:line_item) { create(:subscription_line_item, :with_subscription, spree_line_item: nil) }

      it { is_expected.to be_a Spree::LineItem }
      it { is_expected.to be_frozen }

      it 'has the correct variant' do
        expect(subject.variant_id).to eq line_item.subscribable_id
      end
    end

    context 'with an associated subscription' do
      context 'the associated subscription has an address' do
        let(:line_item) do
          create(:subscription_line_item, :with_subscription, subscription_traits: [:with_address])
        end

        it 'uses the subscription shipping address' do
          expect(subject.order.ship_address).to eq line_item.subscription.shipping_address
        end
      end

      context 'the associated subscription has no address' do
        let(:line_item) { create(:subscription_line_item, :with_subscription) }

        it 'uses the subscription users shipping address' do
          expect(subject.order.ship_address).to eq line_item.subscription.user.ship_address
        end
      end
    end
  end

  describe "#update_actionable_date_if_interval_changed" do
    let(:subscription) { create :subscription }
    let(:line_item) { create :subscription_line_item, subscription: subscription, interval_length: 3, interval_units: "month" }

    before do
      Timecop.freeze(Date.parse("2016-09-22"))
      line_item.subscription.update!(actionable_date: 1.month.ago)
    end
    after { Timecop.return }

    subject { line_item.update!(interval_length: 1, interval_units: "month") }

    context "with installments" do
      before do
        create(:installment, subscription: subscription, created_at: last_installment_date)
      end

      context "when the last installment date would cause the interval to be in the past" do
        let(:last_installment_date) { 2.months.ago }
        it "sets the actionable_date to the current day" do
          subject
          expect(subscription.actionable_date).to eq Time.zone.now
        end
      end

      context "when the last installment date would cause the interval to be in the future" do
        let(:last_installment_date) { 4.days.ago }
        it "sets the actionable_date to an interval from the last installment" do
          subject
          expect(subscription.actionable_date).to eq 1.month.from_now(last_installment_date)
        end
      end
    end

    context "when there are no installments" do
      context "when the subscription creation date would cause the interval to be in the past" do
        before do
          subscription.update(created_at: 4.months.ago)
        end
        it "sets the actionable_date to one interval past the subscription creation date" do
          subject
          expect(subscription.actionable_date).to eq Time.zone.now
        end
      end

      context "when the subscription creation date would cause the interval to be in the future" do
        it "sets the actionable_date to one interval past the subscription creation date" do
          subject
          expect(subscription.actionable_date).to eq Date.parse("2016-10-22")
        end
      end
    end
  end
end
