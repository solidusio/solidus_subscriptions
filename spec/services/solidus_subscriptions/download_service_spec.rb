require "rails_helper"

RSpec.describe "DownloadService" do
  describe "to_csv" do
    let(:search) { nil }
    subject { SolidusSubscriptions::DownloadService.to_csv(search: search)}

    context "with no subscriptions" do
      context " and empty default filter" do
        it "returns just the headers" do
          expect(subject).to eql "first_name,last_name,email,product_name,variant_sku,subscription_date,next_actionable_date,state,processing_state\n"
        end
      end
    end

    context "with subscriptions present" do
      let(:user) { create(:user) }
      let!(:actionable_subscription) do
        create :subscription, :with_line_item, :with_address, :actionable, actionable_date: (Date.current + 1.month), user: user
      end

      let!(:canceled_subscription) do
        create :subscription, :with_line_item, :with_address, :canceled, user: user
      end

      context " and an empty default filter" do
        it "returns all the subscriptions" do
          csv = subject
          expect(csv.lines.count).to eql 3 #including headers!
          expect(csv).to include(user.email)
          expect(csv).to include(actionable_subscription.line_items.first.spree_line_item.product.sku)
          expect(csv).to include(actionable_subscription.actionable_date.to_s)
          expect(csv).to include(actionable_subscription.state)

          expect(csv).to include(canceled_subscription.line_items.first.spree_line_item.product.sku)
          expect(csv).to include(canceled_subscription.state)
        end
      end

      context " and a ransack filter" do
        let(:search) do
          SolidusSubscriptions::Subscription.ransack(state_eq: 'canceled')
        end

        it "returns the filtered subscriptions" do
          csv = subject
          expect(csv.lines.count).to eql 2 #including headers!
          expect(csv).to include(canceled_subscription.line_items.first.spree_line_item.product.sku)
          expect(csv).to include(canceled_subscription.state)

          expect(csv).to_not include(actionable_subscription.line_items.first.spree_line_item.product.sku)
        end
      end
    end
  end
end
