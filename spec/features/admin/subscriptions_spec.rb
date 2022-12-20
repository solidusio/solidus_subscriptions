# frozen_string_literal: true

RSpec.describe 'Subscriptions admin' do
  stub_authorization!

  let(:shipping_address_fieldset) { 'Shipping Address' }
  let(:billing_address_fieldset) { 'Billing Address' }

  it 'Updating a subscription' do
    subscription = create(:subscription, :with_shipping_address, :with_billing_address)

    visit spree.admin_path
    click_link 'Subscriptions'
    find('.fa-edit').click
    within_fieldset(shipping_address_fieldset) do
      fill_in 'Zip Code', with: '33166'
    end
    within_fieldset(billing_address_fieldset) do
      fill_in 'Zip Code', with: '33167'
    end
    click_button 'Update'
    subscription.reload

    expect(subscription.shipping_address.zipcode).to eq('33166')
    expect(subscription.billing_address.zipcode).to eq('33167')
  end

  it 'Creates a subscription' do # rubocop:disable RSpec/MultipleExpectations
    variant = create(:variant, subscribable: true)
    create(:user)
    create(:store)

    visit spree.admin_path
    click_link 'Subscriptions'
    click_link 'New Subscription'
    fill_in 'Actionable date', with: '01/01/2020'
    fill_in 'Interval length', with: 2
    fill_in 'End date', with: '01/03/2020'

    [shipping_address_fieldset, billing_address_fieldset].each do |fieldset|
      within_fieldset(fieldset) do
        name_input_label = if Spree.solidus_gem_version >= Gem::Version.new('2.11.0')
                             'Name'
                           else
                             'First Name'
                           end

        fill_in name_input_label, with: 'John Doe'
        fill_in 'Street Address', with: 'Street Address'
        fill_in 'City', with: 'City'
        fill_in 'Zip Code', with: '33166'
        fill_in 'Phone', with: '1234567890'
      end
    end

    select variant.pretty_name, from: 'Subscribable'
    fill_in 'Quantity', with: 1

    expect(SolidusSubscriptions::Subscription.count).to eq(0)

    # The State field is controlled by JS, so we need to set it at the last moment
    # available.
    state_id = Spree::State.last.id.to_s
    find('input#subscription_shipping_address_attributes_state_id', visible: :all).set(state_id)
    find('input#subscription_billing_address_attributes_state_id', visible: :all).set(state_id)

    click_on 'Create'

    expect(SolidusSubscriptions::Subscription.count).to eq(1)

    expect(page).to have_text('Subscription has been successfully created!')
  end
end
