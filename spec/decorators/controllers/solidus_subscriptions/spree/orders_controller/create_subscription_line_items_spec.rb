# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusSubscriptions::Spree::OrdersController::CreateSubscriptionLineItems, type: :controller do
  controller(Spree::OrdersController) {}
  routes { Spree::Core::Engine.routes }

  let!(:user) { create :user }

  before do
    allow(controller).to receive_messages(spree_current_user: user)
    create :store
  end

  describe 'POST /orders/populate' do
    subject(:populate) { post :populate, params: params }

    let!(:variant) { create :variant }
    let(:params) { line_item_params }
    let(:line_item_params) do
      {
        quantity: 1,
        variant_id: variant.id
      }
    end

    shared_examples 'a new order line item' do
      it { is_expected.to redirect_to cart_path }

      it 'creates an order' do
        expect { populate }.
          to change(Spree::Order, :count).
          from(0).to(1)
      end

      it 'creates a line item' do
        expect { populate }.
          to change(Spree::LineItem, :count).
          from(0).to(1)
      end
    end

    context 'with subscription_line_item params' do
      let(:params) { line_item_params.merge(subscription_line_item_params) }
      let(:subscription_line_item_params) do
        {
          subscription_line_item: {
            quantity: 2,
            end_date: Date.parse('2000/10/11'),
            subscribable_id: variant.id,
            interval_length: 30,
            interval_units: "day"
          }
        }
      end

      it_behaves_like 'a new order line item'

      it 'creates a new subscription line item' do
        expect { populate }.
          to change(SolidusSubscriptions::LineItem, :count).
          from(0).to(1)
      end

      it 'creates a subscription line item with the correct values' do
        populate
        subscription_line_item = SolidusSubscriptions::LineItem.last

        expect(subscription_line_item).to have_attributes(
          subscription_line_item_params[:subscription_line_item]
        )
      end
    end

    context 'without subscription_line_item params' do
      it_behaves_like 'a new order line item'
    end
  end
end
