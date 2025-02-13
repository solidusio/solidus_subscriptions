require 'spec_helper'
require_relative '../../../lib/generators/solidus_subscriptions/install/templates/app/controllers/concerns/create_subscription'

RSpec.describe CreateSubscription, type: :controller do
  subject(:controller_instance) do
    Class.new(ApplicationController) do
      include CreateSubscription
    end.new
  end

  let(:variant) { create(:variant) }
  let(:order) { create(:order) }

  before do
    allow(controller_instance).to receive(:current_order).and_return(order)
  end

  describe '#subscription_line_item_params_present?' do
    context 'when all required params are present' do
      it 'returns true' do
        controller_instance.params = {
          subscription_line_item: {
            subscribable_id: 1,
            quantity: 2,
            interval_length: 1
          }
        }
        expect(controller_instance.send(:valid_subscription_line_item_params?)).to be true
      end
    end

    context 'when required params are missing' do
      it 'returns false' do
        controller_instance.params = {
          subscription_line_item: {
            subscribable_id: '',
            quantity: '',
            interval_length: ''
          }
        }
        expect(controller_instance.send(:valid_subscription_line_item_params?)).to be false
      end
    end
  end

  describe '#handle_subscription_line_items' do
    before do
      allow(controller_instance).to receive(:params).and_return(params)
    end

    context 'when subscription params are missing' do
      let(:params) do
        {
          variant_id: variant.id,
          subscription_line_item: {}
        }
      end

      it 'does not invoke handle_subscription_line_items and does not create a subscription line item' do
        expect(controller_instance.send(:valid_subscription_line_item_params?)).to be false

        expect(controller_instance).not_to receive(:handle_subscription_line_items)

        expect(controller_instance).not_to receive(:create_subscription_line_item)
      end
    end

    context 'when subscription params are present' do
      let(:params) do
        {
          variant_id: variant.id,
          subscription_line_item: {
            subscribable_id: 1,
            quantity: 2,
            interval_length: 1
          }
        }
      end

      it 'calls create_subscription_line_item with the correct line item' do
        line_item = create(:line_item, order: order, variant: variant)

        allow(order.line_items).to receive(:find_by).with(variant_id: variant.id).and_return(line_item)

        expect(controller_instance).to receive(:create_subscription_line_item).with(line_item)

        controller_instance.send(:handle_subscription_line_items)
      end
    end
  end
end
