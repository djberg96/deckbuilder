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

    # select Game One from the dropdown and ensure the page updates
    find('#filter_game').select('Game One')

    # After selection the form should submit and the page should only show Alpha
    expect(page).to have_current_path(cards_path(game_id: game1.id))
    expect(page).to have_content('Alpha')
    expect(page).not_to have_content('Beta')
  end
end
