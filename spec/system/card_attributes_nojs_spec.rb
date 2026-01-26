require 'rails_helper'

RSpec.describe 'Card attributes (no-js)', type: :system do
  before do
    driven_by :rack_test
  end

  it 'renders the add attribute button in the edit form' do
    game = create(:game)
    card = create(:card, game: game, data: { 'type' => 'Creature' })

    visit edit_card_path(card)
    # Save page html for debugging
    save_page('tmp/capybara/debug_edit_card.html')
    puts "Saved page to tmp/capybara/debug_edit_card.html"
    expect(page).to have_selector('#add-attribute')
  end
end
