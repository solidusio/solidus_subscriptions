require 'rails_helper'

RSpec.describe SolidusSubscriptions::Subscription, type: :model do
  it { is_expected.to have_many :installments }
  it { is_expected.to belong_to :user }
  it { is_expected.to have_one :line_item }
  it { is_expected.to validate_presence_of :user }

  describe '#cancel' do
    subject { subscription.cancel }

    let(:subscription) { create :subscription, :with_line_item }

    context 'the subscription can be canceled' do
      it 'is canceled' do
        subject
        expect(subscription.canceled?).to be_truthy
      end
    end

    context 'the subscription cannot be canceled' do
      before do
        allow(subscription).to receive(:can_be_canceled?).and_return(false)
      end

      it 'is pending cancelation' do
        subject
        expect(subscription.pending_cancellation?).to be_truthy
      end
    end
  end

  describe '#deactivate' do
    subject { subscription.deactivate }

    let(:traits) { [] }
    let(:subscription) do
      create :subscription, :with_line_item, line_item_traits: traits
    end

    context 'the subscription can be deactivated' do
      let(:traits) do
        [{ max_installments: 0 }]
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
end
