require 'rails_helper'

RSpec.describe 'Cards filter by game', type: :request do
  it 'shows only cards belonging to selected game' do
    game1 = create(:game, name: 'Game One')
    game2 = create(:game, name: 'Game Two')

    c1 = create(:card, name: 'Alpha', game: game1)
    c2 = create(:card, name: 'Beta', game: game2)

    user = create(:user)
    post login_path, params: { username: user.username, password: 'password123' }

    get cards_path, params: { game_id: game1.id }
    expect(response).to have_http_status(:ok)
    expect(response.body).to include('Alpha')
    expect(response.body).not_to include('Beta')
  end
end
