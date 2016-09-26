require "rails_helper"

RSpec.describe "Subscription endpoints", type: :request do
  let(:json_resp) { JSON.parse(response.body) }
  let(:user) { create :user }
  before { user.generate_spree_api_key! }

  describe "#cancel" do
    let(:subscription) { create :subscription, user: user }

    it "returns the canceled record", :aggregate_failures do
      post solidus_subscriptions.cancel_api_v1_subscription_path(subscription), token: user.spree_api_key
      expect(json_resp["state"]).to eq "canceled"
      expect(json_resp["actionable_date"]).to be_nil
    end
  end
end
