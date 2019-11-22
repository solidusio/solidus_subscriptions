require 'spec_helper'

RSpec.describe SolidusSubscriptions::Subscription, type: :model do
  it { is_expected.to have_many :installments }
  it { is_expected.to belong_to :user }
  it { is_expected.to belong_to :store }
  it { is_expected.to have_many :line_items }
  it { is_expected.to belong_to :shipping_address }

  it { is_expected.to validate_presence_of :user }
  it { is_expected.to validate_presence_of :skip_count }
  it { is_expected.to validate_presence_of :successive_skip_count }
  it { is_expected.to validate_numericality_of(:skip_count).is_greater_than_or_equal_to(0) }
  it { is_expected.to validate_numericality_of(:successive_skip_count).is_greater_than_or_equal_to(0) }

  it { is_expected.to accept_nested_attributes_for :line_items }

  describe '#cancel' do
    subject { subscription.cancel }

    let(:subscription) do
      create :subscription, :with_line_item, actionable_date: actionable_date
    end

    around { |e| Timecop.freeze { e.run } }

    context 'the subscription can be canceled' do
      let(:actionable_date) { 1.month.from_now }

      it 'is canceled' do
        subject
        expect(subscription.canceled?).to be_truthy
      end
    end

    context 'the subscription cannot be canceled' do
      let(:actionable_date) { Date.current }

      it 'is pending cancelation' do
        subject
        expect(subscription.pending_cancellation?).to be_truthy
      end
    end
  end

  describe '#skip' do
    subject { subscription.skip }

    let(:total_skips) { 0 }
    let(:successive_skips) { 0 }
    let(:expected_date) { 1.month.from_now.beginning_of_minute }

    let(:subscription) do
      create(
        :subscription,
        :with_line_item,
        skip_count: total_skips,
        successive_skip_count: successive_skips
      )
    end

    around(:all) do |e|
      successive_skip_limit = SolidusSubscriptions::Config.maximum_successive_skips
      total_skip_limit = SolidusSubscriptions::Config.maximum_total_skips

      SolidusSubscriptions::Config.maximum_successive_skips = 1
      SolidusSubscriptions::Config.maximum_total_skips = 1

      Timecop.freeze { e.run }

      SolidusSubscriptions::Config.maximum_successive_skips = successive_skip_limit
      SolidusSubscriptions::Config.maximum_total_skips = total_skip_limit
    end

    context 'when the successive skips have been exceeded' do
      let(:successive_skips) { 1 }
      it { is_expected.to be_falsy }

      it 'adds errors to the subscription' do
        subject
        expect(subscription.errors[:successive_skip_count]).to_not be_empty
      end
    end

    context 'when the total skips have been exceeded' do
      let(:total_skips) { 1 }
      it { is_expected.to be_falsy }

      it 'adds errors to the subscription' do
        subject
        expect(subscription.errors[:skip_count]).to_not be_empty
      end
    end

    context 'when the subscription can be skipped' do
      it { is_expected.to eq expected_date }
    end
  end

  describe '#deactivate' do
    subject { subscription.deactivate }

    let(:traits) { [] }
    let(:subscription) do
      create :subscription, :actionable, :with_line_item, line_item_traits: traits do |s|
        s.installments = build_list(:installment, 2)
      end
    end

    context 'the subscription can be deactivated' do
      let(:traits) do
        [{ end_date: Date.current.ago(2.days) }]
      end

      it 'is inactive' do
        subject
        expect(subscription.inactive?).to be_truthy
      end
    end

    context 'the subscription cannot be deactivated' do
      it { is_expected.to be_falsy }
    end
  end

  describe '#next_actionable_date' do
    subject { subscription.next_actionable_date }

    context "when the subscription is active" do
      let(:expected_date) { Date.current + subscription.interval }
      let(:subscription) do
        build_stubbed(
          :subscription,
          :with_line_item,
          actionable_date: Date.current
        )
      end

      it { is_expected.to eq expected_date }
    end

    context "when the subscription is not active" do
      let(:subscription) { build_stubbed :subscription, :with_line_item, state: :canceled }
      it { is_expected.to be_nil }
    end
  end

  describe '#advance_actionable_date' do
    subject { subscription.advance_actionable_date }

    let(:expected_date) { Date.current + subscription.interval }
    let(:subscription) do
      build(
        :subscription,
        :with_line_item,
        actionable_date: Date.current
      )
    end

    it { is_expected.to eq expected_date }

    it 'updates the subscription with the new actionable date' do
      subject
      expect(subscription.reload).to have_attributes(
        actionable_date: expected_date
      )
    end
  end

  describe ".actionable" do
    let!(:past_subscription) { create :subscription, actionable_date: 2.days.ago }
    let!(:future_subscription) { create :subscription, actionable_date: 1.month.from_now }
    let!(:inactive_subscription) { create :subscription, state: "inactive", actionable_date: 7.days.ago }
    let!(:canceled_subscription) { create :subscription, state: "canceled", actionable_date: 4.days.ago }

    subject { described_class.actionable }

    it "returns subscriptions that have an actionable date in the past" do
      expect(subject).to include past_subscription
    end

    it "does not include future subscriptions" do
      expect(subject).to_not include future_subscription
    end

    it "does not include inactive subscriptions" do
      expect(subject).to_not include inactive_subscription
    end

    it "does not include canceled subscriptions" do
      expect(subject).to_not include canceled_subscription
    end
  end

  describe '#line_item_builder' do
    subject { subscription.line_item_builder }

    let(:subscription) { create :subscription, :with_line_item }
    let(:line_items) { subscription.line_items }

    it { is_expected.to be_a SolidusSubscriptions::LineItemBuilder }
    it { is_expected.to have_attributes(subscription_line_items: line_items) }
  end

  describe '#processing_state' do
    subject { subscription.processing_state }

    context 'when the subscription has never been processed' do
      let(:subscription) { build_stubbed :subscription }
      it { is_expected.to eq 'pending' }
    end

    context 'when the last processing attempt failed' do
      let(:subscription) do
        create(
          :subscription,
          installments: create_list(:installment, 1, :failed)
        )
      end

      it { is_expected.to eq 'failed' }
    end

    context 'when the last processing attempt succeeded' do
      let(:order) { create :completed_order_with_totals }

      let(:subscription) do
        create(
          :subscription,
          installments: create_list(
            :installment,
            1,
            :success,
            details: build_list(:installment_detail, 1, order: order, success: true)
          )
        )
      end

      it { is_expected.to eq 'success' }
    end
  end

  describe '.ransackable_scopes' do
    subject { described_class.ransackable_scopes }
    it { is_expected.to match_array [:in_processing_state] }
  end

  describe '.in_processing_state' do
    subject { described_class.in_processing_state(state) }

    let!(:new_subs) { create_list :subscription, 2 }
    let!(:failed_subs) { create_list(:installment, 2, :failed).map(&:subscription) }
    let!(:success_subs) { create_list(:installment, 2, :success).map(&:subscription) }

    context 'successfull subscriptions' do
      let(:state) { :success }
      it { is_expected.to match_array success_subs }
    end

    context 'failed subscriptions' do
      let(:state) { :failed }
      it { is_expected.to match_array failed_subs }
    end

    context 'new subscriptions' do
      let(:state) { :pending }
      it { is_expected.to match_array new_subs }
    end

    context 'unknown state' do
      let(:state) { :foo }

      it 'raises an error' do
        expect { subject }.to raise_error ArgumentError, /state must be one of/
      end
    end
  end

  describe '.processing_states' do
    subject { described_class.processing_states }
    it { is_expected.to match_array [:pending, :success, :failed] }
  end
end
