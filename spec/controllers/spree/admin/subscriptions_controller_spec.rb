require 'rails_helper'
RSpec.describe Spree::Admin::SubscriptionsController, type: :request do
  extend Spree::TestingSupport::AuthorizationHelpers::Request
  stub_authorization!

  describe 'get :index' do
    subject do
      get spree.admin_subscriptions_path
      response
    end

    it { is_expected.to be_successful }

    context 'with a frozen time' do
      before { Timecop.freeze(2018, 11, 10) }

      context 'with subscription data' do
        let(:subscription_line_items) { create_list(:subscription_line_item, 5) }
        let!(:recurring_subscription) { create(:subscription, actionable_date: Date.current, line_items: subscription_line_items[0..1], interval_length: 2, interval_units: :week) }
        let!(:inactive_subscription) { create(:subscription, actionable_date: Date.tomorrow, state: :canceled, line_items: [subscription_line_items[2]]) }
        let!(:today_subscription) { create(:subscription, actionable_date: Date.current, line_items: [subscription_line_items[3]]) }
        let!(:tomorrow_subscription) { create(:subscription, actionable_date: Date.tomorrow, line_items: [subscription_line_items[4]]) }

        before { subject }

        it 'assigns quick stats' do
          expect(assigns(:total_active_subs)).to eq 3
          expect(assigns(:monthly_recurring_revenue)).to eq 60.0 # revenue of all active subscriptions with one recurring
          expect(assigns(:todays_recurring_revenue)).to eq 30.0 # revenue of recurring and today subscription
          expect(assigns(:tomorrows_recurring_revenue)).to eq 10.0 # revenue of tomorrow subscription
        end
      end
    end
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
