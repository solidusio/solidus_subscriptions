require "rails_helper"

RSpec.describe SolidusSubscriptions::Api::V1::SubscriptionsController, type: :controller do
  routes { SolidusSubscriptions::Engine.routes }

  let!(:user) { create :user }
  before { user.generate_spree_api_key! }

  shared_examples "an authenticated subscription" do
    context "when the subscription belongs to user" do
      let!(:subscription) do
        create(
          :subscription,
          :with_line_item,
          actionable_date: (Date.current + 1.month ),
          user: user
        )
      end

      it { is_expected.to be_success }
    end

    context "when the subscription belongs to someone else" do
      let!(:subscription) { create :subscription, user: create(:user) }
      it { is_expected.to be_not_found }
    end

    context 'when the subscription is canceled' do
      let!(:subscription) { create :subscription, user: user, state: 'canceled' }
      it { is_expected.to be_unprocessable }
    end
  end

  describe 'PATCH :update' do
    subject { patch :update, params: params }
    let(:params) do
      {
        id: subscription.id,
        token: user.spree_api_key,
        subscription: subscription_params
      }
    end

    let(:subscription_params) do
      {
        line_items_attributes: [{
          id: subscription.line_items.first.id,
          quantity: 6
        }],
        shipping_address_attributes: {
          firstname: 'Ash',
          lastname: 'Ketchum',
          address1: '1 Rainbow Road',
          city: 'Palette Town',
          country_id: create(:country).id,
          state_id: create(:state).id,
          phone: '999-999-999',
          zipcode: '10001'
        }
      }
    end

    context 'when the subscription belongs to the user' do
      let!(:subscription) { create :subscription, :with_line_item, user: user }
      it { is_expected.to be_success }

      context 'when the params are not valid' do
        let(:subscription_params) do
          {
            line_items_attributes: [{
              id: subscription.line_items.first.id,
              quantity: -6
            }]
          }
        end

        it { is_expected.to have_http_status(:unprocessable_entity) }
      end
    end

    context 'when the subscription belongs to someone else' do
      let!(:subscription) { create :subscription, :with_line_item, user: create(:user) }
      it { is_expected.to be_not_found }
    end
  end

  describe "POST :skip" do
    let(:params) { { id: subscription.id, token: user.spree_api_key } }
    subject { post :skip, params: params }

    it_behaves_like "an authenticated subscription"
  end

  describe "POST :cancel" do
    let(:params) { { id: subscription.id, token: user.spree_api_key } }
    subject { post :cancel, params: params }

    it_behaves_like "an authenticated subscription"
  end
end
