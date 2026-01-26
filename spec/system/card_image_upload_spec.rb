require 'rails_helper'

RSpec.describe 'Card image uploads', type: :system do
  before do
    driven_by :selenium_firefox_headless
  end

  it 'shows an error when uploading an image larger than 64 KB and prevents submission', js: true do
    user = create(:user, username: 'uploader', password: 'password123')
    login_as(user)

    create(:game, name: 'G1', edition: 'E1', minimum_cards_per_deck: 10, maximum_cards_per_deck: 60, maximum_individual_cards: 4)
    visit new_card_path

    fill_in 'Name', with: 'Img Card'
    fill_in 'Description', with: 'Has large image'
    select 'G1 (E1)', from: 'Game'

    attach_file('card[new_images][]', Rails.root.join('spec/fixtures/large.bin'), make_visible: true)

    # Client-side should display an error and disable submission
    expect(page).to have_content(/exceed|Image upload failed/)
    create_btn = find_button('Create Card', disabled: true)
    expect(create_btn[:disabled]).to be_truthy

    # Form should not have been submitted (no card created)
    expect(page).to have_current_path(new_card_path)
    expect(Card.count).to eq(0)
  end
end
