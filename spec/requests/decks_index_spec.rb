require 'rails_helper'

RSpec.describe 'Decks index', type: :request do
  it 'shows game name and total number of cards for each deck' do
    user = create(:user)
    game = create(:game, name: 'Test Game')
    deck = create(:deck, user: user)
    # associate game via game_deck
    deck.create_game_deck(game: game)
    create(:deck_card, deck: deck, card: create(:card, game: game), quantity: 3)

    post login_path, params: { username: user.username, password: 'password123' }
    get decks_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Test Game')
    expect(response.body).to include('3')
  end
end
