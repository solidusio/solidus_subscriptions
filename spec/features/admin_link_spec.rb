require 'spec_helper'

RSpec.feature 'Subscriptions admin link', type: :feature do
  stub_authorization!

  scenario 'Navigating to the subscriptions backend' do
    visit '/admin'
    click_on "Subscriptions"
    expect(page.current_path).to match /admin\/subscriptions/
  end
end
