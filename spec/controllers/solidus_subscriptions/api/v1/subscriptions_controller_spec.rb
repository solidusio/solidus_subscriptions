require "rails_helper"

RSpec.describe SolidusSubscriptions::Api::V1::SubscriptionsController, type: :controller do
  routes { SolidusSubscriptions::Engine.routes }

  let!(:user) { create :user }
  before { user.generate_spree_api_key! }

  describe "POST :cancel" do
    let(:params) { { id: subscription.id, token: user.spree_api_key } }
    subject { post :cancel, params }

    context "when the subscription belongs to user" do
      let!(:subscription) { create :subscription, user: user }
      it { is_expected.to be_success }
    end

    context "when the subscription belongs to someone else" do
      let!(:subscription) { create :subscription, user: create(:user) }
      it { is_expected.to be_not_found }
    end
  end

  describe 'PATCH :update' do
    subject { patch :update, params }
    let(:params) do
      {
        id: subscription.id,
        token: user.spree_api_key,
        subscription: subscription_params
      }
    end

    let(:subscription_params) do
      {
        line_item_attributes: {
          id: subscription.line_item.id,
          quantity: 6
        }
      }
    end

    context 'when the subscription belongs to the user' do
      let!(:subscription) { create :subscription, :with_line_item, user: user }
      it { is_expected.to be_success }

      context 'when the params are not valid' do
        let(:subscription_params) do
          {
            line_item_attributes: {
              id: subscription.line_item.id,
              quantity: -6
            }
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
end
