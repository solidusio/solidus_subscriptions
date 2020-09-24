require 'spec_helper'

RSpec.describe 'Subscriptions admin link', type: :feature do
  stub_authorization!

  it 'Navigating to the subscriptions backend' do
    visit '/admin'
    click_on "Subscriptions"
    expect(page).to have_current_path %r{admin/subscriptions}
  end
end
