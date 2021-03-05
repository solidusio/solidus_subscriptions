RSpec.describe 'Installments tab admin' do
  stub_authorization!

  it 'Viewing an installment' do
    create(:installment, :success)

    visit spree.admin_path
    click_link 'Subscriptions'
    find('.fa-edit').click
    click_link 'Installments'

    within('#listing_installments tbody') do
      expect(page).to have_content('Fulfilled')
    end
  end
end
