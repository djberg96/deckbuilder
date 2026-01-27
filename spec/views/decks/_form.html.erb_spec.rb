require 'rails_helper'

RSpec.describe 'decks/_form.html.erb', type: :view do
  let(:deck) { Deck.new.tap { |d| d.build_game_deck } }
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
    expect(rendered).to have_selector('h5', text: 'Add cards', visible: false)
  end

  it 'includes submit button' do
    render partial: 'decks/form', locals: { deck: deck, games: games, cards_by_game: cards_by_game }
    expect(rendered).to have_selector('input[type="submit"]')
  end

  it 'renders card select options sorted alphabetically by name' do
    # create cards in unsorted order
    game = create(:game)
    c1 = create(:card, name: 'Zeta', game: game)
    c2 = create(:card, name: 'Alpha', game: game)

    cards_sorted = Card.order(:name).map { |c| {id: c.id, name: c.name, game_id: c.game_id} }
    assign(:cards_by_game, cards_sorted)

    # build a deck with one deck_card to render the select
    deck_with_card = Deck.new
    deck_with_card.build_game_deck
    deck_with_card.deck_cards.build

    render partial: 'decks/form', locals: { deck: deck_with_card, games: games, cards_by_game: cards_sorted }

    # find the select markup and assert Alpha comes before Zeta
    rendered_select = rendered.match(/<select[^>]*class="form-control card-select"[^>]*>(.*?)<\/select>/m)[1]
    expect(rendered_select.index('>Alpha')).to be < rendered_select.index('>Zeta')
  end
end