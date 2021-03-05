# frozen_string_literal: true

RSpec.describe 'Subscription orders admin' do
  stub_authorization!

  let(:subscription) { create(:subscription, :with_shipping_address, :with_billing_address) }

  before do
    visit spree.edit_admin_subscription_path(subscription)
    within('.tabs') { click_link 'Orders' }
  end

  it 'shows a No orders messages' do
    expect(page).to have_css('legend', text: 'Orders')
    expect(page).to have_content(/No orders found/i)
  end

  context 'with some orders' do
    let(:orders) { build_list(:order, 3, subscription_order: true) }
    let(:subscription) do
      create(:subscription, :with_shipping_address, :with_billing_address).tap do |subscription|
        subscription.orders << orders
      end
    end

    it 'lists the orders of a subscription' do
      expect(page).to have_css('.admin_subscription_order', count: orders.size)
      within('#listing_subscription_orders') do
        orders.each do |order|
          expect(page).to have_content(order.number)
        end
      end
    end
  end
end
