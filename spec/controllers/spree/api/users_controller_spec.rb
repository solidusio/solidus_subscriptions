# frozen_string_literal: true

require 'spec_helper'
require 'spree/api/testing_support/helpers'

RSpec.describe Spree::Api::UsersController, type: :controller do
  include Spree::Api::TestingSupport::Helpers
  routes { Spree::Core::Engine.routes }

  let!(:user) do
    create(:user, &:generate_spree_api_key).tap(&:save)
  end
  let!(:subscription) { create :subscription, :with_line_item, user: user }

  describe 'patch /update' do
    subject(:update_user) { patch :update, params: params }

    let(:params) do
      {
        id: user.id,
        token: user.spree_api_key,
        format: 'json',
        user: {
          subscriptions_attributes: [{
            id: subscription.id,
            line_items_attributes: [line_item_attributes]
          }]
        }
      }
    end

    let(:line_item_attributes) do
      {
        id: subscription.line_item_ids.first,
        quantity: 6,
        interval_length: 1,
        interval_units: 'month'
      }
    end

    it 'updates the subscription line items' do
      allow(::Spree::Deprecation).to receive(:warn).with(a_string_matching(
        'Creating or updating subscriptions through Spree::User nested attributes is deprecated'
      ))
      update_user
      line_item = subscription.line_items.reload.first

      expect(line_item).to have_attributes(line_item_attributes)
    end
  end
end
