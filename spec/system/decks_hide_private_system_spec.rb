require 'rails_helper'

RSpec.describe 'Decks hide private toggle', type: :system do
  before do
    driven_by :selenium_firefox_headless
  end

  it 'hides private decks owned by others when checkbox is checked', js: true do
    owner = create(:user, username: 'owner9', password: 'password123')
    viewer = create(:user, username: 'viewer9', password: 'password123')
    g = create(:game)

    d1 = create(:deck, name: 'Owners Deck', user: owner, private: true); d1.create_game_deck(game: g)
    d2 = create(:deck, name: 'Public Deck', user: owner, private: false); d2.create_game_deck(game: g)

    login_as(viewer)
    visit decks_path

    # both decks visible initially
    expect(page).to have_content('Owners Deck')
    expect(page).to have_content('Public Deck')

    # toggle the hide control (now an icon/label)
    find('label[for="hide_private_others"]').click

    expect(page).not_to have_content('Owners Deck')
    expect(page).to have_content('Public Deck')

    # toggle again - should show again
    find('label[for="hide_private_others"]').click
    expect(page).to have_content('Owners Deck')
  end
end
