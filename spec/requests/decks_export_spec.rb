require 'rails_helper'

RSpec.describe "Deck Exports", type: :request do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:deck) { create(:deck, user: user, game: game) }

  before do
    create(:deck_card, deck: deck, card: create(:card, game: game), quantity: 2)
  end

  it "exports JSON" do
    get deck_path(deck, format: :json)
    expect(response).to be_successful
    json = JSON.parse(response.body)
    expect(json['name']).to eq(deck.name)
    expect(json['deck_cards']).to be_an(Array)
    expect(json['deck_cards'].first['quantity']).to eq(2)
  end

  it "exports XML" do
    get deck_path(deck, format: :xml)
    expect(response).to be_successful
    expect(response.content_type).to include 'xml'
    expect(response.body).to include(deck.name)
  end

  it "exports PDF" do
    get deck_path(deck, format: :pdf)
    expect(response).to be_successful
    expect(response.headers['Content-Type']).to include 'application/pdf'
    expect(response.headers['Content-Disposition']).to include 'attachment'
    expect(response.body.bytesize).to be > 100
  end
end
