require 'rails_helper'
require 'spree/api/testing_support/helpers'

RSpec.describe Spree::Api::LineItemsController, type: :controller do
  include Spree::Api::TestingSupport::Helpers
  routes { Spree::Core::Engine.routes }

  describe 'POST :create' do
    subject { post :create, params }

    let(:params) { line_item_params }
    let!(:variant) { create :variant }
    let!(:order) { create :order }

    let(:line_item_params) do
      {
        order_id: order.number,
        order_token: order.guest_token,
        format: 'json',
        line_item: {
          quantity: 1,
          variant_id: variant.id
        }
      }
    end

    shared_examples 'a new line item' do
      it { is_expected.to be_created }

      it 'creates a line item' do
        expect { subject }.
          to change { Spree::LineItem.count }.
          from(0).to(1)
      end
    end

    context 'with subscription_line_item params' do
      let(:params) { line_item_params.merge(subscription_line_item_params) }
      let(:subscription_line_item_params) do
        {
          subscription_line_item: {
            quantity: 2,
            max_installments: 3,
            subscribable_id: variant.id,
            interval_length: 30,
            interval_units: "day"
          }
        }
      end

      it_behaves_like 'a new line item'

      it 'creates a new subscription line item' do
        expect { subject }.
          to change { SolidusSubscriptions::LineItem.count }.
          from(0).to(1)
      end

      it 'creates a subscription line item with the correct values' do
        subject
        subscription_line_item = SolidusSubscriptions::LineItem.last

        expect(subscription_line_item).to have_attributes(
          subscription_line_item_params[:subscription_line_item]
        )
      end
    end

    context 'without subscription_line_item params' do
      it_behaves_like 'a new line item'
    end
  end
end
