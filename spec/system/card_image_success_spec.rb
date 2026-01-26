require 'rails_helper'

RSpec.describe 'Card image uploads (success)', type: :system do
  before do
    driven_by :selenium_firefox_headless
  end

  it 'uploads a small image and saves it to the database', js: true do
    user = create(:user, username: 'uploader2', password: 'password123')
    login_as(user)

    create(:game, name: 'G2', edition: 'E2', minimum_cards_per_deck: 10, maximum_cards_per_deck: 60, maximum_individual_cards: 4)
    visit new_card_path

    # ensure the form is multipart so uploads are possible
    expect(find('form#card-form')[:enctype]).to eq('multipart/form-data')

    fill_in 'Name', with: 'Img Card 2'
    fill_in 'Description', with: 'Has small image'
    select 'G2 (E2)', from: 'Game'

    attach_file('card[new_images][]', Rails.root.join('spec/fixtures/small.png'), make_visible: true)
    click_button 'Create Card'

    # It should redirect to the created card's show page
    card = Card.last
    expect(page).to have_current_path(card_path(card))

    # Image should be persisted and visible on show page
    expect(card.card_images.count).to eq(1)
    expect(page).to have_css('img[src^="data:"]')
  end
end
