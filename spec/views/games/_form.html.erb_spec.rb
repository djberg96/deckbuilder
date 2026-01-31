require 'rails_helper'

RSpec.describe 'games/_form.html.erb', type: :view do
  it 'renders minimum_cards_per_deck input with min 10 and default value 10 for new game' do
    assign(:game, Game.new)

    render partial: 'games/form', locals: { game: Game.new }

    expect(rendered).to have_selector('input[type="number"][name="game[minimum_cards_per_deck]"][min="10"][value="10"]')
  end

  it 'renders minimum_cards_per_deck as at least 10 for existing game with less than 10' do
    game = build(:game, minimum_cards_per_deck: 5)
    assign(:game, game)

    render partial: 'games/form', locals: { game: game }

    expect(rendered).to have_selector('input[type="number"][name="game[minimum_cards_per_deck]"][min="10"][value="10"]')
  end
end
