require 'rails_helper'

RSpec.describe "Card image uploads (server-side)", type: :request do
  let(:game) { create(:game) }

  it 'rejects oversized images on create and shows server error' do
    user = create(:user, username: 'requploader', password: 'password123')
    post login_path, params: { username: user.username, password: 'password123' }

    large_file = fixture_file_upload(Rails.root.join('spec/fixtures/large.bin'), 'image/png')

    post cards_path, params: { card: { name: 'X', description: 'Y', game_id: game.id, new_images: [large_file] } }

    expect(response.body).to include('Image upload failed')
    expect(Card.count).to eq(0)
  end

  it 'rejects oversized images on update and shows server error' do
    user = create(:user, username: 'requploader2', password: 'password123')
    post login_path, params: { username: user.username, password: 'password123' }

    card = create(:card, game: game)
    large_file = fixture_file_upload(Rails.root.join('spec/fixtures/large.bin'), 'image/png')

    patch card_path(card), params: { card: { name: card.name, new_images: [large_file] } }

    expect(response.body).to include('Image upload failed')
    card.reload
    expect(card.card_images.count).to eq(0)
  end
end
