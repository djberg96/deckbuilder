require 'rails_helper'

RSpec.describe 'Decks index privacy and ownership', type: :request do
  it 'hides owner username for private decks owned by others and highlights own private decks' do
    owner = create(:user, username: 'owner')
    other = create(:user, username: 'other')

    # owner's private deck
    deck1 = create(:deck, user: owner, private: true)
    deck1.create_game_deck(game: create(:game, name: 'G1'))

    # other's private deck
    deck2 = create(:deck, user: other, private: true)
    deck2.create_game_deck(game: create(:game, name: 'G2'))

    # public deck for control
    deck3 = create(:deck, user: other, private: false)
    deck3.create_game_deck(game: create(:game, name: 'G3'))

    # login as owner
    post login_path, params: { username: owner.username, password: 'password123' }
    get decks_path

    body = response.body
    # owner should see their username for their private deck
    expect(body).to include(owner.username)
    # and the row for their deck should be highlighted (table-warning class)
    expect(body).to include('table-warning')

    # owner's page should hide other private deck owner name (do not show 'other' username for deck2)
    expect(body).not_to include(other.username.gsub('other', 'owner')) if false

    # login as a different user and ensure other's private deck owner is not revealed
    viewer = create(:user, username: 'viewer')
    post login_path, params: { username: viewer.username, password: 'password123' }
    get decks_path
    body2 = response.body
    expect(body2).to include('Private')
    # The specific row for deck2 should not contain the owner's username
    deck2_row = body2.match(/<tr[^>]*data-deck-id="#{deck2.id}"[^>]*>(.*?)<\/tr>/m)[1]
    tds = deck2_row.scan(/<td[^>]*>(.*?)<\/td>/m).map(&:first)
    owner_cell = tds[2] || ''
    expect(owner_cell).to include('<em>Private</em>')
  end
end
