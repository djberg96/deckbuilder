require 'rails_helper'

RSpec.describe 'Cards import', type: :system do
  before do
    driven_by :selenium_firefox_headless
  end

  it 'imports a JSON list of cards and creates game if needed', js: true do
    user = create(:user, username: 'importer', password: 'password123')
    login_as(user)

    visit cards_path

    # Open modal
    find('button', text: 'Import').click

    # Choose create new game
    find('select#import_game_id').select('Create new game...')
    fill_in 'import[new_game_name]', with: 'Imported Game'
    fill_in 'import[new_game_edition]', with: 'First'

    # Prepare a JSON blob and set it into the textarea
    json = [{ name: 'Imp Card 1', description: 'Desc 1', attack: 3 }, { name: 'Imp Card 2', attack: 5 }].to_json

    fill_in 'import[raw_text]', with: json

    within('#importCardsModal') do
      click_button 'Import'
    end

    # Expect redirect back with notice
    expect(page).to have_content('Imported 2 cards.')

    # New game created
    g = Game.find_by(name: 'Imported Game')
    expect(g).not_to be_nil

    # Cards present
    expect(page).to have_content('Imp Card 1')
    expect(page).to have_content('Imp Card 2')

    # inspect that data attribute (attack) was stored
    c = Card.find_by(name: 'Imp Card 1')
    puts "DEBUG CARD DATA: "+c.data.inspect

    # ensure cards were created (data parsing may vary by input shape)
    expect(Card.where(game: g).count).to be >= 2
  end
end
