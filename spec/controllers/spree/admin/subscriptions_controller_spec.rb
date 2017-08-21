require 'rails_helper'
RSpec.describe Spree::Admin::SubscriptionsController, type: :request do
  extend Spree::TestingSupport::AuthorizationHelpers::Request
  stub_authorization!

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
    subject { put spree.admin_subscription_path(subscription), params: subscription_params }

    let(:expected_date) { DateTime.parse('2001/11/12') }
    let(:subscription) { create :subscription, :actionable }
    let(:subscription_params) do
      {
        subscription: { actionable_date: expected_date }
      }
    end

    it { is_expected.to redirect_to spree.admin_subscriptions_path }

    it 'updates the subscription attributes', :aggregate_failures do
      expect { subject }.to change { subscription.reload.actionable_date }.to expected_date
    end
  end

  describe 'POST cancel' do
    subject { delete spree.cancel_admin_subscription_path(subscription) }
    context 'the subscription can be canceled' do
      let(:subscription) { create :subscription, :actionable }

      it { is_expected.to redirect_to spree.admin_subscriptions_path }

      it 'has a message' do
        subject
        expect(flash[:notice]).to be_present
      end

      it 'cancels the subscription' do
        expect { subject }.to change { subscription.reload.state }.from('active').to('canceled')
      end
    end

    context 'the subscription cannot be canceled' do
      let(:subscription) { create :subscription, :canceled }

      it { is_expected.to redirect_to spree.admin_subscriptions_path }

      it 'has a message' do
        subject
        expect(flash[:notice]).to be_present
      end

      it 'cancels the subscription' do
        expect { subject }.to_not change { subscription.reload.state }
      end
    end
  end

  describe 'POST activate' do
    subject { post spree.activate_admin_subscription_path(subscription) }

    context 'the subscription can be activated' do
      let(:subscription) { create :subscription, :canceled, :with_line_item }

      it { is_expected.to redirect_to spree.admin_subscriptions_path }

      it 'has a message' do
        subject
        expect(flash[:notice]).to be_present
      end

      it 'cancels the subscription' do
        expect { subject }.to change { subscription.reload.state }.from('canceled').to('active')
      end
    end

    context 'the subscription cannot be activated' do
      let(:subscription) { create :subscription, :actionable, :with_line_item }

      it { is_expected.to redirect_to spree.admin_subscriptions_path }

      it 'has a message' do
        subject
        expect(flash[:notice]).to be_present
      end

      it 'cancels the subscription' do
        expect { subject }.to_not change { subscription.reload.state }
      end
    end
  end

  describe 'POST skip' do
    subject { post spree.skip_admin_subscription_path(subscription) }

    let(:subscription) { create :subscription, :actionable, :with_line_item }
    let!(:expected_date) { subscription.next_actionable_date }

    it { is_expected.to redirect_to spree.admin_subscriptions_path }

    it 'has a message' do
      subject
      expect(flash[:notice]).to be_present
    end

    it 'advances the actioanble_date' do
      expect { subject }.
        to change { subscription.reload.actionable_date }.
        from(subscription.actionable_date).to(expected_date)
    end
  end
end
