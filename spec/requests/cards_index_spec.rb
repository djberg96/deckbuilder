require 'rails_helper'

RSpec.describe 'Cards index', type: :request do
  it 'lists cards sorted alphabetically by name' do
    game = create(:game)
    c1 = create(:card, name: 'Zeta', game: game)
    c2 = create(:card, name: 'Alpha', game: game)

    user = create(:user, username: 'idxuser', password: 'password123')
    post login_path, params: { username: user.username, password: 'password123' }

    get cards_path
    expect(response).to have_http_status(:ok)
    body = response.body
    # ensure Alpha occurs before Zeta
    expect(body.index('Alpha')).to be < body.index('Zeta')
  end
end
