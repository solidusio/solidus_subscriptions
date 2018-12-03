require 'rails_helper'

RSpec.feature 'Subscription purchase cycle', type: :feature do
  stub_authorization!

  let!(:store) { create(:store) }
  let!(:variant) { product.master }
  let!(:shipping_method) { create(:shipping_method) }
  let!(:payment_method) { create(:credit_card_payment_method, active: true, available_to_users: true) }
  let!(:product) { create(:product_in_stock) }
  let!(:admin) { create(:admin_user, password: 'secret', password_confirmation: 'secret') }

  let(:guest_email) { 'freddy@fred.com' }

  before do
    variant.update_attributes(subscribable: true)
  end

  scenario 'Purchasing a subscription variant', js: true do
    visit '/'
    click_link product.name, title: product.name
    fill_in 'I want', with: '2'
    fill_in 'every', with: '1'
    choose 'month'
    click_on 'Add To Cart'
    click_on 'Checkout'
    within('#guest_checkout') do
      fill_in 'Email', with: guest_email
      click_on 'Continue'
    end
    # Billing / shipping addresses
    expect(page).to have_text("Billing Address")
    fill_in_address
    click_on "Save and Continue"

    # Shipping
    expect(page).to have_text("DELIVERY", count: 2)
    click_on "Save and Continue"

    # Payment
    expect(page).to have_text("PAYMENT INFORMATION")
    fill_in_payment_info
    click_on "Save and Continue"

    # Confirmation page
    expect(page).to have_text("CONFIRM", count: 2)
    click_on "Place Order"

    expect(page).to have_text("Thank you for your business.")

    visit '/admin/subscriptions'
    expect(page).to have_content(guest_email)
  end

  def fill_in_address
    addr_base = "order_bill_address_attributes"
    fill_in "#{addr_base}_firstname", with: "Ryan"
    fill_in "#{addr_base}_lastname", with: "Bigg"
    fill_in "#{addr_base}_address1", with: "125 Oak Street"
    fill_in "#{addr_base}_city", with: "Memphis"
    select "United States of America", from: "#{addr_base}_country_id"
    select "Alabama", from: "#{addr_base}_state_id"
    fill_in "#{addr_base}_zipcode", with: "73579"
    fill_in "#{addr_base}_phone", with: "(555) 555-5555"
  end

  def fill_in_payment_info
    fill_in "Card Number", with: "1"
    fill_in "Expiration", with: "01/25"
    fill_in "Card Code", with: "123"
  end
end
