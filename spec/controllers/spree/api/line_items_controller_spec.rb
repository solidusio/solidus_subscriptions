# frozen_string_literal: true

require 'spec_helper'
require 'spree/api/testing_support/helpers'

RSpec.describe Spree::Api::LineItemsController, type: :controller do
  include Spree::Api::TestingSupport::Helpers
  routes { Spree::Core::Engine.routes }

  describe 'POST :create' do
    subject(:post_create) { post :create, params: params }

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
        expect { post_create }.
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
            end_date: '1990/10/12',
            subscribable_id: variant.id,
            interval_length: 30,
            interval_units: "day"
          }
        }
      end

      it_behaves_like 'a new line item'

      it 'creates a new subscription line item' do
        expect { post_create }.
          to change(SolidusSubscriptions::LineItem, :count).
          from(0).to(1)
      end
    end

    context 'without subscription_line_item params' do
      it_behaves_like 'a new line item'
    end
  end

  describe 'patch :update' do
    subject(:patch_update) { patch :update, params: params }

    let(:params) { line_item_params }

    context 'when adding subscription information' do
      let(:variant) { create :variant }
      let(:order) { create :order }
      let(:line_item) { create :line_item, order: order, variant: variant }
      let(:line_item_params) do
        {
          id: line_item.id,
          order_id: order.number,
          order_token: order.guest_token,
          format: 'json',
          line_item: {
            quantity: 1,
            variant_id: variant.id
          },
          subscription_line_item: {
            quantity: 2,
            end_date: '1990/10/12',
            subscribable_id: variant.id,
            interval_length: 30,
            interval_units: "day"
          }
        }
      end

      it { is_expected.to be_successful }

      it 'creates a new subscription line item' do
        expect { patch_update }.
          to change(SolidusSubscriptions::LineItem, :count).
          from(0).to(1)
      end
    end

    context 'when updating subscription information' do
      let!(:line_item) { create :subscription_line_item, interval_length: 30 }
      let(:variant) { line_item.spree_line_item.variant }
      let(:order) { line_item.spree_line_item.order }
      let(:line_item_params) do
        {
          id: line_item.spree_line_item.id,
          order_id: order.number,
          order_token: order.guest_token,
          format: 'json',
          line_item: {
            quantity: 1,
          },
          subscription_line_items_attributes: {
            id: line_item.id,
            interval_length: 15,
          }
        }
      end

      it { is_expected.to be_successful }

      it 'does not create a new subscription line item' do
        expect { patch_update }.
          not_to change(SolidusSubscriptions::LineItem, :count)
      end

      it 'updates a new subscription line item' do
        expect { patch_update }.
          to change { line_item.reload.interval_length }.from(30).to(15)
      end
    end
  end
end
