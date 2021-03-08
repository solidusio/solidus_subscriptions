RSpec.describe 'Subscription events tab admin' do
  stub_authorization!

  it 'Viewing a subscription event' do
    create(:subscription_event, event_type: 'new_event_type')

    visit spree.admin_path
    click_link 'Subscriptions'
    find('.fa-edit').click
    click_link 'Events'

    within('#listing_subscription_events tbody') do
      expect(page).to have_content('new_event_type')
    end
  end
end
