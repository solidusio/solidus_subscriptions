require 'rails_helper'

RSpec.describe Spree::Admin::SubscriptionsController, type: :controller do
  routes { Spree::Core::Engine.routes }
  stub_authorization!

  describe 'get /admin/subscriptions' do
    subject { get :index }

    it { is_expected.to be_successful }
  end

  describe 'GET :new' do
    subject { get :new }

    it { is_expected.to be_successful }
  end

  describe 'POST cancel' do
    subject { delete :cancel, params: { id: subscription.id } }
    context 'the subscription can be canceled' do
      let(:subscription) { create :subscription, :actionable }

      it { is_expected.to redirect_to admin_subscriptions_path }

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

      it { is_expected.to redirect_to admin_subscriptions_path }

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
    subject { post :activate, params: { id: subscription.id } }

    context 'the subscription can be activated' do
      let(:subscription) { create :subscription, :canceled, :with_line_item }

      it { is_expected.to redirect_to admin_subscriptions_path }

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

      it { is_expected.to redirect_to admin_subscriptions_path }

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
    subject { post :skip, params: { id: subscription.id } }

    let(:subscription) { create :subscription, :actionable, :with_line_item }
    let!(:expected_date) { subscription.next_actionable_date }

    it { is_expected.to redirect_to admin_subscriptions_path }

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
