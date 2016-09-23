require "rails_helper"

RSpec.describe SolidusSubscriptions::Api::V1::LineItemsController, type: :controller do
  routes { SolidusSubscriptions::Engine.routes }

  let!(:user) { create(:user) }
  before { user.generate_spree_api_key! }

  describe "#update" do
    let(:line) { create :subscription_line_item, order: order }
    let(:params) do
      {
        id: line.id,
        subscription_line_item: { quantity: 21 },
        token: user.spree_api_key
      }
    end
    subject { post :update, params }

    context "when the order belongs to the user" do
      let(:order) { create :order, user: user }

      context "with valid params" do
        let(:json_body) { JSON.parse(subject.body) }

        it { is_expected.to be_success }
        it "returns the updated record" do
          expect(json_body["quantity"]).to eq 21
        end
      end

      context "with invalid params" do
        let(:params) do
          {
            id: line.id,
            subscription_line_item: { max_installments: "lots" },
            token: user.spree_api_key
          }
        end

        it { is_expected.to be_unprocessable }
      end
    end

    context "when the order belongs to someone else" do
      let(:order) { create :order, user: create(:user) }
      it { is_expected.to be_unauthorized }
    end
  end
end
