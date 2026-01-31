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

  it 'renders a remove button for existing deck cards' do
    # create a persisted deck with a deck_card so the persisted branch is rendered
    game = create(:game)
    card = create(:card, game: game, name: 'Exists')
    deck = create(:deck, user: create(:user))
    deck.build_game_deck(game: game)
    dc = deck.deck_cards.create!(card: card, quantity: 1)

    assign(:deck, deck)
    assign(:games, games)
    assign(:cards_by_game, cards_by_game)

    render partial: 'decks/form', locals: { deck: deck, games: games, cards_by_game: cards_by_game }

    expect(rendered).to have_selector('button.remove-existing-card', text: 'Remove')
    # persisted rows should include the nested deck_card id so _destroy will target it
    expect(rendered).to have_selector('input[type="hidden"][name*="[id]"]')
  end

  it 'includes games max mapping and sets max on existing quantity inputs' do
    game = create(:game, maximum_individual_cards: 3)
    assign(:games, Game.all)

    # build a deck with a persisted deck_card so we get a quantity input
    user = create(:user)
    deck = create(:deck, user: user)
    deck.build_game_deck(game: game)
    dc = deck.deck_cards.create!(card: create(:card, game: game), quantity: 2)

    assign(:deck, deck)
    assign(:cards_by_game, Card.all.map { |c| { id: c.id, name: c.name, game_id: c.game_id } })

    render partial: 'decks/form', locals: { deck: deck, games: games, cards_by_game: cards_by_game }

    # gamesByMax mapping should be present and include our game's max
    expect(rendered).to match(/var gamesByMax = .*"#{game.id}"\s*:\s*#{game.maximum_individual_cards}/)

    # existing quantity input should have max attribute
    expect(rendered).to have_selector('input[type="number"][max="3"]')
  end
end