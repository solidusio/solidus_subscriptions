require 'spec_helper'

RSpec.describe SolidusSubscriptions::LineItemBuilder do
  let(:builder) { described_class.new subscription_line_items }
  let(:variant) { create(:variant, subscribable: true) }
  let(:subscription_line_item) { subscription_line_items.first }
  let(:subscription_line_items) do
    build_stubbed_list(:subscription_line_item, 1, subscribable_id: variant.id)
  end

  describe '#spree_line_items' do
    subject { builder.spree_line_items }
    let(:expected_attributes) do
      {
        variant_id: subscription_line_item.subscribable_id,
        quantity: subscription_line_item.quantity
      }
    end

    it { is_expected.to be_a Array }

    it 'contains a line item with the correct attributes' do
      expect(subject.first).to have_attributes expected_attributes
    end

    context 'the variant is not subscribable' do
      let!(:variant) { create(:variant) }

      it 'raises an unsubscribable error' do
        expect { subject }.to raise_error(
          SolidusSubscriptions::UnsubscribableError,
          /cannot be subscribed to/
        )
      end
    end

    context 'the variant is out of stock' do
      before { create :stock_location, backorderable_default: false }
      it { is_expected.to be_empty }
    end
  end
end
