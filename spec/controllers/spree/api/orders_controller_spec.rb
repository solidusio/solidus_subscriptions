# frozen_string_literal: true

require 'spec_helper'
require 'spree/api/testing_support/helpers'

RSpec.describe Spree::Api::OrdersController, type: :controller do
  include Spree::Api::TestingSupport::Helpers
  routes { Spree::Core::Engine.routes }

  let(:order) { create :order }
  let(:variant) { create :variant }

  describe 'patch /update' do
    subject(:subscription_line_items) do
      patch :update, params: params
      order.subscription_line_items.reload
    end

    before { stub_authentication! }

    let(:params) do
      {
        order: { line_items_attributes: [line_items_params] },
        id: order.to_param,
        format: 'json',
        order_token: order.guest_token
      }
    end

    let(:line_items_params) do
      {
        variant_id: variant.id,
        quantity: 1,
        subscription_line_items_attributes: [subscription_line_items_params]
      }
    end

    let(:subscription_line_items_params) do
      {
        quantity: 1,
        subscribable_id: variant.id,
        interval_length: 30,
        interval_units: "day"
      }
    end

    it 'is a successful response' do
      subscription_line_items
      expect(response).to be_successful
    end

    it 'create the correct number of subscription line items' do
      expect(subscription_line_items.length).
        to eq line_items_params[:subscription_line_items_attributes].length
    end
  end
end
