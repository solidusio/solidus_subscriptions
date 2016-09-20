require "rails_helper"

RSpec.describe SolidusSubscriptions::Api::V1::LineItemsController, type: :controller do
  routes { SolidusSubscriptions::Engine.routes }

  let!(:user) { create(:user) }
  before { user.generate_spree_api_key! }

  describe "#update" do
    let!(:line) { create :subscription_line_item }
    subject { post :update, params }

    context "with valid params" do
      let(:params) do
        {
          id: line.id,
          subscription_line_item: { max_installments: 24 },
          token: user.spree_api_key
        }
      end
      let(:json_body) { JSON.parse(subject.body) }

      it { is_expected.to be_success }
      it "returns the updated record" do
        expect(json_body["max_installments"]).to eq 24
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
end
