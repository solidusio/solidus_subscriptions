# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'User subscriptions tab', type: :feature do
  stub_authorization!

  let(:user) { create(:user) }

  before do
    allow(Spree.user_class).to receive(:find_by).
      with(hash_including(:id)).
      and_return(user)
  end

  context 'when user has subscriptions' do
    let!(:subscription) {
      create(:subscription,
        actionable_date: '2020-10-21',
        interval_length: 10,
        interval_units: :day,
        user: user)
    }

    before do
      visit '/admin/'
      click_link 'Users'
      click_link subscription.user.email
      within('.tabs') { click_link 'Subscriptions' }
    end

    it 'lists user subscriptions date' do
      subscriptions_table = page.find('#subscriptions-table')

      expect(subscriptions_table).to have_content('2020-10-21')
    end

    it 'lists user subscriptions days' do
      subscriptions_table = page.find('#subscriptions-table')

      expect(subscriptions_table).to have_content('10 days')
    end

    it 'shows edit link to subscriptions' do
      page.find("#subscriptions-table td.actions a.fa-edit").click

      expect(page).to have_current_path spree.edit_admin_subscription_path(subscription), ignore_query: true
    end
  end

  context 'when user does not have subscriptions' do
    it 'displays no found message when user has no subscriptions' do
      visit spree.admin_path
      click_link 'Users'
      click_link user.email
      within('.tabs') { click_link 'Subscriptions' }

      expect(page).to have_content('No Subscriptions found.')
    end
  end
end
