require 'spec_helper'
require_relative '../../../lib/generators/solidus_subscriptions/install/templates/app/controllers/concerns/create_subscription'

RSpec.describe CreateSubscription, type: :controller do
  subject(:controller_instance) do
    Class.new(ApplicationController) do
      include CreateSubscription
      attr_accessor :params, :current_order

      def initialize(params = {})
        @params = params
        @current_order = nil
      end
    end.new
  end

  let(:variant) { create(:variant) }
  let(:order) { create(:order) }

  before do
    controller_instance.current_order = order
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
        expect(controller_instance.send(:subscription_line_item_params_present?)).to be true
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
        expect(controller_instance.send(:subscription_line_item_params_present?)).to be false
      end
    end
  end

  describe '#handle_subscription_line_items' do
    context 'when subscription params are missing' do
      it 'does not invoke handle_subscription_line_items and does not create a subscription line item' do
        initial_line_item_count = order.line_items.count

        controller_instance.params = {
          variant_id: variant.id,
          subscription_line_item: {}
        }

        expect(controller_instance.send(:subscription_line_item_params_present?)).to be false

        expect(controller_instance).not_to receive(:handle_subscription_line_items)

        expect(controller_instance).not_to receive(:create_subscription_line_item)
      end
    end

    context 'when subscription params are present' do
      it 'calls create_subscription_line_item with the correct line item' do
        line_item = create(:line_item, order: order, variant: variant)

        controller_instance.params = {
          variant_id: variant.id,
          subscription_line_item: {
            subscribable_id: 1,
            quantity: 2,
            interval_length: 1
          }
        }

        allow(order.line_items).to receive(:find_by).with(variant_id: variant.id).and_return(line_item)

        expect(controller_instance).to receive(:create_subscription_line_item).with(line_item)

        controller_instance.send(:handle_subscription_line_items)
      end
    end
  end
end
