# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SolidusSubscriptions::SubscriptionGenerator do
  describe '.from_order' do
    it 'creates the correct number of subscriptions' do
      order = create(:order, :with_subscription_line_items)

      expect { described_class.from_order(order) }.to change(SolidusSubscriptions::Subscription, :count).by(1)
    end

    it 'creates subscriptions with the correct attributes', :aggregate_failures do
      order = create(:order, :with_subscription_line_items)
      subscription_line_items = order.subscription_line_items
      subscription_line_item = subscription_line_items.first

      described_class.from_order(order)

      subscription = SolidusSubscriptions::Subscription.last
      expect(subscription).to be_present
      expect(subscription.line_items).to match_array(subscription_line_items)
      expect(subscription).to have_attributes(
        user: order.user,
        shipping_address: order.ship_address,
        billing_address: order.bill_address,
        interval_length: subscription_line_item.interval_length,
        interval_units: subscription_line_item.interval_units,
        end_date: subscription_line_item.end_date,
        store: order.store,
        currency: order.currency
      )
    end

    it 'uses the payment source from the order payments when available', :aggregate_failures do
      order = create(:order, :with_subscription_line_items)
      subscription_line_items = order.subscription_line_items
      subscription_line_item = subscription_line_items.first
      payment_method = create(:credit_card_payment_method)
      payment_source = create(:credit_card, payment_method: payment_method, user: order.user)
      create(:payment,
        order: subscription_line_item.spree_line_item.order,
        source: payment_source,
        payment_method: payment_method,)

      described_class.from_order(order)

      subscription = SolidusSubscriptions::Subscription.last
      expect(subscription).to be_present
      expect(subscription).to have_attributes(
        payment_method: payment_method,
        payment_source: payment_source,
      )
    end

    it 'uses the payment source from the user wallet when no order payments are present', :aggregate_failures do
      user = create(:user)
      order = create(:order, :with_subscription_line_items, user: user)
      payment_method = create(:credit_card_payment_method)
      payment_source = create(:credit_card, payment_method: payment_method, user: user)
      user.wallet.add(payment_source)

      described_class.from_order(order)

      subscription = SolidusSubscriptions::Subscription.last
      expect(subscription).to be_present
      expect(subscription).to have_attributes(
        payment_method: payment_method,
        payment_source: payment_source,
      )
    end

    it 'cleanups the subscription line items fields duplicated on the subscription' do
      attrs = { interval_length: 2, interval_units: :week, end_date: Time.zone.tomorrow }
      subscription_line_item = create(:subscription_line_item, attrs)
      order = subscription_line_item.order

      described_class.from_order(order)

      expect(subscription_line_item.reload).to have_attributes(
        interval_length: nil,
        interval_units: nil,
        end_date: nil
      )
    end
  end

  describe '.subscription_configuration' do
    it 'creates a subscription configuration with the correct values', :aggregate_failures do
      order = create(:order, :with_subscription_line_items)
      subscription_line_item = order.subscription_line_items.first

      subscription_configuration = described_class.subscription_configuration(subscription_line_item)

      expect(subscription_configuration.interval_length).to eq(subscription_line_item.interval_length)
      expect(subscription_configuration.interval_units).to eq(subscription_line_item.interval_units)
      expect(subscription_configuration.end_date).to eq(subscription_line_item.end_date)
    end
  end
end
