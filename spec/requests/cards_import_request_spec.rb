require 'rails_helper'

RSpec.describe 'Cards import', type: :request do
  it 'creates game and cards from JSON payload' do
    user = User.create!(username: 'requser', password: 'password123')
    post login_path, params: { username: 'requser', password: 'password123' }
    follow_redirect!
    expect(response.body).to include('Decks')

    json = [{ name: 'X1', description: 'D1', power: 2 }].to_json
    post import_cards_path, params: { import: { raw_text: json, new_game_name: 'Req Game', new_game_edition: 'E1' } }
    follow_redirect!
    expect(response.body).to include('Imported 1 cards.')
    g = Game.find_by(name: 'Req Game')
    expect(g).not_to be_nil
    c = Card.find_by(name: 'X1')
    expect(c).not_to be_nil
    expect(c.game).to eq(g)
  end
end
