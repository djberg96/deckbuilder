require 'rails_helper'

RSpec.describe 'Decks filter (system)', type: :system do
  before do
    driven_by :selenium_firefox_headless
  end

  it 'filters decks client-side by selected column and value', js: true do
    owner = create(:user, username: 'own1', password: 'password123')
    other = create(:user, username: 'other1', password: 'password123')
    g1 = create(:game, name: 'Game A')
    g2 = create(:game, name: 'Game B')

    d1 = create(:deck, name: 'Deck A', user: owner); d1.create_game_deck(game: g1)
    d2 = create(:deck, name: 'Deck B', user: other); d2.create_game_deck(game: g2)

    login_as(owner)
    visit decks_path

    # choose Game in column select, then choose Game A in value select
    find('#deck_filter_column').select('Game')
    find('#deck_filter_value').select('Game A')

    expect(page.current_url).to include('filter_column=game')
    expect(page.current_url).to include('filter_value=' + g1.id.to_s)
    expect(page).to have_content('Deck A')
    expect(page).not_to have_content('Deck B')

    # switch to owner column and filter by owner username
    find('#deck_filter_column').select('Owner')
    find('#deck_filter_value').select('own1')

    expect(page.current_url).to include('filter_column=owner')
    expect(page.current_url).to include('filter_value=' + owner.id.to_s)
    expect(page).to have_content('Deck A')
    expect(page).not_to have_content('Deck B')

    # selecting 'All' should clear filters and show all decks
    find('#deck_filter_column').select('All')

    expect(page.current_url).not_to include('filter_column=')
    expect(page.current_url).not_to include('filter_value=')
    expect(page).to have_content('Deck A')
    expect(page).to have_content('Deck B')
  end
end
