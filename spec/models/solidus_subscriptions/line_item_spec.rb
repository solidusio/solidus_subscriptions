require 'spec_helper'

RSpec.describe SolidusSubscriptions::LineItem, type: :model do
  it { is_expected.to validate_presence_of :subscribable_id }

  it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0) }
  it { is_expected.to validate_numericality_of(:interval_length).is_greater_than(0) }

  describe '#save!' do
    context 'when the line item is new' do
      it 'tracks a line_item_created event' do
        line_item = build(:subscription_line_item, :with_subscription)

        line_item.save!

        expect(line_item.subscription.events.last).to have_attributes(
          event_type: 'line_item_created',
          details: a_hash_including('id' => line_item.id),
        )
      end
    end

    context 'when the line item is persisted' do
      it 'tracks a line_item_updated event' do
        line_item = create(:subscription_line_item, :with_subscription)

        line_item.quantity = 2
        line_item.save!

        expect(line_item.subscription.events.last).to have_attributes(
          event_type: 'line_item_updated',
          details: a_hash_including('id' => line_item.id),
        )
      end
    end
  end

  describe '#destroy!' do
    it 'tracks a line_item_destroyed event' do
      line_item = create(:subscription_line_item, :with_subscription)

      line_item.destroy!

      expect(line_item.subscription.events.last).to have_attributes(
        event_type: 'line_item_destroyed',
        details: a_hash_including('id' => line_item.id),
      )
    end
  end

  describe "#interval" do
    subject { line_item.interval }

    let(:line_item) { create :subscription_line_item, :with_subscription }

    before do
      Timecop.freeze(Date.parse("2016-09-22"))
      line_item.subscription.update!(actionable_date: Date.current)
    end

    after { Timecop.return }

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
      context 'the associated subscription has a shipping address' do
        let(:line_item) do
          create(:subscription_line_item, :with_subscription, subscription_traits: [:with_shipping_address])
        end

        it 'uses the subscription shipping address' do
          expect(subject.order.ship_address).to eq line_item.subscription.shipping_address
        end

        it 'uses the subscription users billing address' do
          expect(subject.order.bill_address).to eq line_item.subscription.user.bill_address
        end
      end

      context 'the associated subscription has a billing address' do
        let(:line_item) do
          create(:subscription_line_item, :with_subscription, subscription_traits: [:with_billing_address])
        end

        it 'uses the subscription users shipping address' do
          expect(subject.order.ship_address).to eq line_item.subscription.user.ship_address
        end

        it 'uses the subscription billing address' do
          expect(subject.order.bill_address).to eq line_item.subscription.billing_address
        end
      end
    end
  end
end
