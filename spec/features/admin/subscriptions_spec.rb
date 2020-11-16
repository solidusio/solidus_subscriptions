RSpec.describe 'Subscriptions admin' do
  stub_authorization!

  it 'Updating a subscription' do
    subscription = create(:subscription, :with_shipping_address, :with_billing_address)

    visit spree.admin_path
    click_link 'Subscriptions'
    find('.fa-edit').click
    fill_in 'subscription[shipping_address_attributes][zipcode]', with: '33166'
    fill_in 'subscription[billing_address_attributes][zipcode]', with: '33167'
    click_button 'Update'
    subscription.reload

    expect(subscription.shipping_address.zipcode).to eq('33166')
    expect(subscription.billing_address.zipcode).to eq('33167')
  end
end
