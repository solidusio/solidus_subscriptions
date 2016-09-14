require 'rails_helper'

RSpec.describe SolidusSubscriptions::LineItemBuilder do
  let(:builder) { described_class.new subscription_line_item }
  let!(:variant) { create(:variant, subscribable: true) }
  let(:subscription_line_item) do
    build_stubbed(:subscription_line_item, subscribable_id: variant.id)
  end

  describe '#line_item' do
    subject { builder.line_item }
    let(:expected_attributes) do
      {
        variant_id: subscription_line_item.subscribable_id,
        quantity: subscription_line_item.quantity
      }
    end

    it { is_expected.to be_a Spree::LineItem }
    it { is_expected.to have_attributes expected_attributes }

    context 'the variant is not subscribable' do
      let!(:variant) { create(:variant) }

      it 'raises an unsubscribable error' do
        expect { subject }.to raise_error(
          SolidusSubscriptions::UnsubscribableError,
          /cannot be subscribed to/
        )
      end
    end
  end
end
