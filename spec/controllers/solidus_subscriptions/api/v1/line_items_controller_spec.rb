require 'spec_helper'

RSpec.describe SolidusSubscriptions::Api::V1::LineItemsController, type: :controller do
  routes { SolidusSubscriptions::Engine.routes }

  let!(:user) { create(:user) }
  let(:line) { create :subscription_line_item, subscription: subscription }

  before { user.generate_spree_api_key! }

  describe "#update" do
    subject { post :update, params: params }

    let(:params) do
      {
        id: line.id,
        subscription_line_item: { quantity: 21 },
        token: user.spree_api_key,
        format: :json
      }
    end

    context "when the subscription belongs to the user" do
      let(:subscription) { create :subscription, user: user }

      context "with valid params" do
        let(:json_body) { JSON.parse(subject.body) }

        it { is_expected.to be_successful }

        it "returns the updated record" do
          expect(json_body["quantity"]).to eq 21
        end
      end

      context "with invalid params" do
        let(:params) do
          {
            id: line.id,
            subscription_line_item: { quantity: -1 },
            token: user.spree_api_key,
            format: :json
          }
        end

        it { is_expected.to be_unprocessable }
      end
    end

    context "when the subscription belongs to someone else" do
      let(:subscription) { create :subscription, user: create(:user) }

      it { is_expected.to be_unauthorized }
    end
  end

  describe "#destroy" do
    subject { delete :destroy, params: params }

    let(:params) {
      {
        id: line.id,
        token: user.spree_api_key,
        format: :json
      }
    }

    context "when the subscription is not ours" do
      let(:subscription) { create :subscription, user: create(:user) }

      it { is_expected.to be_unauthorized }
    end
  end
end
