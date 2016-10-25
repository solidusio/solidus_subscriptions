require 'rails_helper'

RSpec.describe Spree::Admin::SubscriptionsController, type: :controller do
  routes { Spree::Core::Engine.routes }
  stub_authorization!

  describe 'get /admin/subscriptions' do
    subject { get :index }

    it { is_expected.to be_successful }
    it { is_expected.to render_template :index }
  end

  describe 'GET :new' do
    subject { get :new }

    it { is_expected.to be_successful }
    it { is_expected.to render_template :new }
  end

  describe 'POST cancel' do
    subject { delete :cancel, id: subscription.id }
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
end
