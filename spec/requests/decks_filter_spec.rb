require 'rails_helper'

RSpec.describe 'Decks filter by column', type: :request do
  it 'filters by game' do
    user = create(:user)
    game1 = create(:game, name: 'G1')
    game2 = create(:game, name: 'G2')

    d1 = create(:deck, user: user); d1.create_game_deck(game: game1)
    d2 = create(:deck, user: user); d2.create_game_deck(game: game2)

    post login_path, params: { username: user.username, password: 'password123' }
    get decks_path, params: { filter_column: 'game', filter_value: game1.id }

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(d1.name)
    expect(response.body).not_to include(d2.name)
  end

  it 'filters by owner' do
    owner = create(:user, username: 'owner2')
    other = create(:user)

    d1 = create(:deck, user: owner); d1.create_game_deck(game: create(:game))
    d2 = create(:deck, user: other); d2.create_game_deck(game: create(:game))

    post login_path, params: { username: owner.username, password: 'password123' }
    get decks_path, params: { filter_column: 'owner', filter_value: owner.id }

    expect(response.body).to include(d1.name)
    expect(response.body).not_to include(d2.name)
  end
end
