require 'rails_helper'

RSpec.describe 'Cards filter (system)', type: :system do
  before do
    driven_by :selenium_firefox_headless
  end

  it 'filters cards when selecting a game from the dropdown', js: true do
    game1 = create(:game, name: 'Game One')
    game2 = create(:game, name: 'Game Two')

    create(:card, name: 'Alpha', game: game1)
    create(:card, name: 'Beta', game: game2)

    user = create(:user, username: 'filterer', password: 'password123')
    login_as(user)

    visit cards_path

    # ensure both cards shown initially
    expect(page).to have_content('Alpha')
    expect(page).to have_content('Beta')

    # select Game One from the dropdown and ensure the list updates client-side
    find('#filter_game').select('Game One')

    # URL should be updated and list should be filtered
    expect(page.current_url).to include("game_id=#{game1.id}")
    expect(page).to have_content('Alpha')
    expect(page).not_to have_content('Beta')
  end
end
