module LoginHelpers
  def login_as(user)
    visit login_path
    fill_in 'username', with: user.username
    fill_in 'password', with: user.password || 'password123'
    click_button 'Login'
  end
end

RSpec.configure do |config|
  config.include LoginHelpers, type: :system
end
