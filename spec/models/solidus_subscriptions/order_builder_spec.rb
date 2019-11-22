require 'spec_helper'

RSpec.describe SolidusSubscriptions::OrderBuilder do
  let(:builder) { described_class.new order }

  describe '#add_line_items' do
    subject { builder.add_line_items([line_item]) }

    let(:variant) { create :variant, subscribable: true }
    let(:order) do
      create :order, line_items_attributes: line_items_attributes
    end

    let(:line_item) { create(:line_item, quantity: 4, variant: variant) }

    context 'the line item doesnt already exist on the order' do
      let(:line_items_attributes) { [] }

      it 'adds a new line item to the order' do
        expect { subject }.
          to change { order.line_items.count }.
          from(0).to(1)
      end

      it 'has a line item with the correct values' do
        subject
        line_item = order.line_items.last

        expect(line_item).to have_attributes(
          variant_id: variant.id,
          quantity: line_item.quantity
        )
      end
    end

    context 'the line item already exists on the order' do
      let(:line_items_attributes) do
        [{
            variant: variant,
            quantity: 3
        }]
      end

      it 'increases the correct line item by the correct amount' do
        existing_line_item = order.line_items.first

        expect { subject }.
          to change { existing_line_item.reload.quantity }.
          by(line_item.quantity)
      end
    end
  end
end
