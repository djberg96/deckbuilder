require 'rails_helper'

RSpec.describe 'decks/_form.html.erb', type: :view do
  let(:deck) { Deck.new }
  let(:games) { Game.all }
  let(:cards_by_game) { Card.all.map { |c| { id: c.id, name: c.name, game_id: c.game_id } } }

  before do
    assign(:deck, deck)
    assign(:games, games)
    assign(:cards_by_game, cards_by_game)
  end

  it 'renders the form without syntax errors' do
    expect { render partial: 'decks/form', locals: { deck: deck, games: games, cards_by_game: cards_by_game } }.not_to raise_error
    expect(rendered).to have_selector('form')
  end

  it 'includes game selection' do
    render partial: 'decks/form', locals: { deck: deck, games: games, cards_by_game: cards_by_game }
    expect(rendered).to have_selector('select[name="deck[game_deck_attributes][game_id]"]')
  end

  it 'includes card addition section' do
    render partial: 'decks/form', locals: { deck: deck, games: games, cards_by_game: cards_by_game }
    expect(rendered).to have_selector('h5', text: 'Add or Edit Cards')
  end

  it 'includes submit button' do
    render partial: 'decks/form', locals: { deck: deck, games: games, cards_by_game: cards_by_game }
    expect(rendered).to have_selector('input[type="submit"]')
  end

  it 'includes back button' do
    render partial: 'decks/form', locals: { deck: deck, games: games, cards_by_game: cards_by_game }
    expect(rendered).to have_selector('a.btn.btn-secondary', text: 'Back')
  end
end