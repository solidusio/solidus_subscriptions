require "rails_helper"

RSpec.describe "DownloadService" do
  describe "to_csv" do
    context "with no subscriptions" do
      context " and empty default filter" do
        let(:search) { nil }
        subject { SolidusSubscriptions::DownloadService.to_csv(search: search)}

        it "returns just the headers" do
          expect(subject).to eql "first_name,last_name,email,product_name,variant_sku,subscription_date,next_actionable_date,state,processing_state\n"
        end
      end
    end
  end
end
