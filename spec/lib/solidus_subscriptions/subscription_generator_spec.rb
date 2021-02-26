require 'spec_helper'

RSpec.describe SolidusSubscriptions::SubscriptionGenerator do
  describe '.activate' do
    it 'creates the correct number of subscriptions' do
      subscription_line_items = build_list(:subscription_line_item, 2)

      expect {
        described_class.activate(subscription_line_items)
      }.to change(SolidusSubscriptions::Subscription, :count).by(1)
    end

    it 'creates subscriptions with the correct attributes', :aggregate_failures do
      subscription_line_items = build_list(:subscription_line_item, 2)
      subscription_line_item = subscription_line_items.first

      subscription = described_class.activate(subscription_line_items)

      expect(subscription.line_items).to match_array(subscription_line_items)
      expect(subscription).to have_attributes(
        user: subscription_line_item.order.user,
        shipping_address: subscription_line_item.spree_line_item.order.ship_address,
        billing_address: subscription_line_item.spree_line_item.order.bill_address,
        interval_length: subscription_line_item.interval_length,
        interval_units: subscription_line_item.interval_units,
        end_date: subscription_line_item.end_date,
        store: subscription_line_item.order.store,
        currency: subscription_line_item.order.currency
      )
    end

    it 'copies the payment method from the order' do
      subscription_line_item = build(:subscription_line_item)
      payment_method = create(:credit_card_payment_method)
      payment_source = create(:credit_card, payment_method: payment_method)
      create(:payment,
        order: subscription_line_item.spree_line_item.order,
        source: payment_source,
        payment_method: payment_method,)

      subscription = described_class.activate([subscription_line_item])

      expect(subscription).to have_attributes(
        payment_method: payment_method,
        payment_source: payment_source,
      )
    end

    it 'cleanups the subscription line items fields duplicated on the subscription' do
      attrs = { interval_length: 2, interval_units: :week, end_date: Time.zone.tomorrow }
      subscription_line_item = create(:subscription_line_item, attrs)

      described_class.activate([subscription_line_item])

      expect(subscription_line_item.reload).to have_attributes(
        interval_length: nil,
        interval_units: nil,
        end_date: nil
      )
    end
  end

  describe '.group' do
    it 'groups subscriptions by interval and end date' do
      monthly_subscriptions = build_stubbed_list(:subscription_line_item, 2)
      bimonthly_subscriptions = build_stubbed_list(:subscription_line_item, 2, interval_length: 2)
      weekly_subscriptions = build_stubbed_list(:subscription_line_item, 2, interval_units: :week)
      expiring_subscriptions = build_stubbed_list(:subscription_line_item, 2, end_date: Time.zone.tomorrow)

      subscriptions = [
        monthly_subscriptions,
        bimonthly_subscriptions,
        weekly_subscriptions,
        expiring_subscriptions,
      ]
      grouping_result = described_class.group(subscriptions.sum)

      expect(grouping_result).to match_array(subscriptions)
    end
  end
end
