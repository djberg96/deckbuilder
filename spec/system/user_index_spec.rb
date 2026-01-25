require 'rails_helper'

RSpec.describe 'Users index', type: :system do
  before do
    driven_by :rack_test
  end

  it 'navigates to the correct user when clicking the username' do
    user = create(:user, username: 'alice', password: 'password123')
    visit login_path
    fill_in 'username', with: user.username
    fill_in 'password', with: 'password123'
    click_button 'Login'

    visit users_path
    click_link 'alice'
    expect(page).to have_current_path(user_path(user))
    expect(page).to have_content('alice')
  end
end