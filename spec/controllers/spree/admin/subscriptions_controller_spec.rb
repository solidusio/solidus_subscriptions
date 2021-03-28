# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Spree::Admin::SubscriptionsController, type: :request do
  extend Spree::TestingSupport::AuthorizationHelpers::Request
  stub_authorization!

  before do
    ActionController::Base.allow_forgery_protection = false
  end

  after do
    ActionController::Base.allow_forgery_protection = true
  end

  describe 'get /admin/subscriptions' do
    subject do
      get spree.admin_subscriptions_path
      response
    end

    it { is_expected.to be_successful }
  end

  describe 'GET :new' do
    subject do
      get spree.new_admin_subscription_path
      response
    end

    it { is_expected.to be_successful }
  end

  describe 'GET :edit' do
    subject do
      get spree.edit_admin_subscription_path(subscription)
      response
    end

    let(:subscription) { create :subscription, :actionable }

    it { is_expected.to be_successful }
  end

  describe 'PUT :update' do
    it 'redirects to edit subscription page' do
      subscription = create :subscription
      subscription_params = { subscription: { interval_length: 1 } }

      expect(put(spree.admin_subscription_path(subscription), params: subscription_params)).
        to redirect_to spree.edit_admin_subscription_path(subscription)
    end

    it 'updates the subscription attributes', :aggregate_failures do
      expected_date = DateTime.parse('2001/11/12')
      subscription = create :subscription, :actionable
      subscription_params = { subscription: { actionable_date: expected_date } }

      expect { put spree.admin_subscription_path(subscription), params: subscription_params }.
        to change { subscription.reload.actionable_date }.
        to expected_date
    end

    it 'does not duplicate line items' do
      variant = create :variant, subscribable: true
      subscription = create :subscription
      subscription_params = {
        subscription: {
          line_items_attributes: [
            { subscribable_id: variant.id, quantity: 1 }
          ]
        }
      }

      expect { put spree.admin_subscription_path(subscription), params: subscription_params }.
        to change { subscription.reload.line_items.count }.
        by 1
    end

    context 'when updating the payment method' do
      it 'updates the subscription payment method' do
        check_payment_method = create :check_payment_method
        subscription = create :subscription
        subscription_params = { subscription: { payment_method_id: check_payment_method.id } }

        put spree.admin_subscription_path(subscription), params: subscription_params

        expect(subscription.reload).to have_attributes(
          payment_method: check_payment_method,
          payment_source: nil,
        )
      end

      it 'updates the subscription payment source if payment method requires source' do
        payment = create :credit_card_payment
        payment_source = payment.source
        payment_method = payment.payment_method

        subscription = create :subscription, user: payment.order.user
        subscription_params = {
          subscription: {
            payment_method_id: payment_method.id,
            payment_source_id: payment_source.id,
          }
        }

        put spree.admin_subscription_path(subscription), params: subscription_params

        expect(subscription.reload.payment_source).to eq(payment_source)
      end
    end
  end

  describe 'POST cancel' do
    subject(:delete_subscription) { delete spree.cancel_admin_subscription_path(subscription) }

    context 'when the subscription can be canceled' do
      let(:subscription) { create :subscription, :actionable }

      it { is_expected.to redirect_to spree.admin_subscriptions_path }

      it 'has a message' do
        delete_subscription
        expect(flash[:notice]).to be_present
      end

      it 'cancels the subscription' do
        expect { delete_subscription }.to change { subscription.reload.state }.from('active').to('canceled')
      end
    end

    context 'when the subscription cannot be canceled' do
      let(:subscription) { create :subscription, :canceled }

      it { is_expected.to redirect_to spree.admin_subscriptions_path }

      it 'has a message' do
        delete_subscription
        expect(flash[:notice]).to be_present
      end

      it 'cancels the subscription' do
        expect { delete_subscription }.not_to(change { subscription.reload.state })
      end
    end
  end

  describe 'POST activate' do
    subject(:activate) { post spree.activate_admin_subscription_path(subscription) }

    context 'when the subscription can be activated' do
      let(:subscription) { create :subscription, :canceled, :with_line_item }

      it { is_expected.to redirect_to spree.admin_subscriptions_path }

      it 'has a message' do
        activate
        expect(flash[:notice]).to be_present
      end

      it 'cancels the subscription' do
        expect { activate }.to change { subscription.reload.state }.from('canceled').to('active')
      end
    end

    context 'when the subscription cannot be activated' do
      let(:subscription) { create :subscription, :actionable, :with_line_item }

      it { is_expected.to redirect_to spree.admin_subscriptions_path }

      it 'has a message' do
        activate
        expect(flash[:notice]).to be_present
      end

      it 'cancels the subscription' do
        expect { activate }.not_to(change{ subscription.reload.state })
      end
    end
  end

  describe 'POST skip' do
    subject(:skip) { post spree.skip_admin_subscription_path(subscription) }

    let(:subscription) { create :subscription, :actionable, :with_line_item }
    let!(:expected_date) { subscription.next_actionable_date }

    it { is_expected.to redirect_to spree.admin_subscriptions_path }

    it 'has a message' do
      skip
      expect(flash[:notice]).to be_present
    end

    it 'advances the actionable_date' do
      expect { skip }.
        to change { subscription.reload.actionable_date }.
        from(subscription.actionable_date).to(expected_date)
    end
  end
end
