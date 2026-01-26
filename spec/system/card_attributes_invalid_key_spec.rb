require 'rails_helper'

RSpec.describe 'Card attributes invalid key flow', type: :system do
  before do
    driven_by :selenium_firefox_headless
  end

  it 'shows inline error for invalid key and allows correcting then resubmitting', js: true do
    user = create(:user, username: 'fixer', password: 'password123')
    visit login_path
    fill_in 'username', with: user.username
    fill_in 'password', with: 'password123'
    click_button 'Login'

    create(:game, name: 'Flow Game', edition: 'F1', minimum_cards_per_deck: 40, maximum_cards_per_deck: 60, maximum_individual_cards: 4)
    visit new_card_path
    fill_in 'Name', with: 'Flow Card'
    fill_in 'Description', with: 'Testing flow'
    select 'Flow Game (F1)', from: 'Game'
    click_button 'Create Card'
    card = Card.last

    visit edit_card_path(card)

    find('#add-attribute').click
    within all('.data-attribute').last do
      find('.data-key').set('bad-key')
      find('.data-value').set('10')
    end

    click_button 'Update Card'

    # Expect inline error to appear and focus on the key
    expect(page).to have_css('.invalid-feedback', text: 'Keys may contain only letters and numbers.')

    # Correct the key and resubmit
    within all('.data-attribute').last do
      find('.data-key').set('type')
    end

    click_button 'Update Card'

    expect(page).to have_current_path(card_path(card))
    card.reload
    expect(card.data.type).to eq('10')
  end
end
