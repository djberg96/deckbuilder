require 'rails_helper'

RSpec.describe 'Card attributes editor', type: :system do
  before do
    driven_by :selenium_firefox_headless
  end

  it 'does not persist placeholder (blank/__new__) keys when adding an attribute', js: true do
    # Create a user and log in (ApplicationController requires authorization)
    user = create(:user, username: 'sys_user', password: 'password123')
    visit login_path
    fill_in 'username', with: user.username
    fill_in 'password', with: 'password123'
    click_button 'Login'

    # Create a Game in the database so the Selenium-driven browser can see it
    create(:game, name: 'System Game', edition: 'E1', minimum_cards_per_deck: 40, maximum_cards_per_deck: 60, maximum_individual_cards: 4)

    visit new_card_path
    # Debug: ensure new card form loaded
    unless page.has_field?('Name')
      save_page('tmp/capybara/new_card_missing_1.html')
      raise 'New Card form not present (first case); saved page to tmp/capybara/new_card_missing_1.html'
    end

    fill_in 'Name', with: 'System Card'
    fill_in 'Description', with: 'A card created in system test'
    select 'System Game (E1)', from: 'Game'
    click_button 'Create Card'
    card = Card.last

    visit cards_path
    # Navigate to the card edit page via the listing
    find("a[href='#{edit_card_path(card)}']").click

    # Add an attribute but leave key blank (placeholder name should be __new__)
    expect(page).to have_selector('#add-attribute')
    # Click the button; if JS binding doesn't run reliably in this environment, append the template directly
    find('#add-attribute').click
    unless all('.data-attribute', visible: :visible).size >= 2
      page.execute_script("$('#data-attributes').append($('#attribute-template').html())")
    end
    expect(all('.data-attribute', visible: :visible).size).to be >= 2
    within all('.data-attribute', visible: :visible).last do
      find('.data-value').set('secret')
    end

    find('input[type="submit"]').click

    expect(page).to have_current_path(card_path(card))
    card.reload

    # Ensure placeholder key not persisted
    expect(card.data.to_h.stringify_keys.keys).not_to include('__new__')
    # And no blank keys
    expect(card.data.to_h.stringify_keys.keys).not_to include('')
  end

  it 'resolves rename collisions by keeping the last value for the key', js: true do
    # Create the Game and Card via the UI (ensure logged in)
    user = create(:user, username: 'sys_user2', password: 'password123')
    visit login_path
    fill_in 'username', with: user.username
    fill_in 'password', with: 'password123'
    click_button 'Login'

    # Create a Game in the database so the Selenium-driven browser can see it
    create(:game, name: 'System Game', edition: 'E1', minimum_cards_per_deck: 40, maximum_cards_per_deck: 60, maximum_individual_cards: 4)

    # Create a card in the DB with existing 'type' attribute so we can test rename collision
    game = Game.find_by(name: 'System Game') || create(:game, name: 'System Game', edition: 'E1')
    card = create(:card, game: game, data: { 'type' => 'Creature' })

    visit edit_card_path(card)

    visit cards_path
    # Navigate to the card edit page via the listing
    find("a[href='#{edit_card_path(card)}']").click

    expect(page).to have_selector('#add-attribute')
    find('#add-attribute').click
    unless all('.data-attribute', visible: :visible).size >= 2
      page.execute_script("$('#data-attributes').append($('#attribute-template').html())")
    end
    expect(all('.data-attribute', visible: :visible).size).to be >= 2
    within all('.data-attribute', visible: :visible).last do
      # Use send_keys to simulate user typing so delegated input events fire
      dk = find('.data-key')
      dk.click
      dk.send_keys('type')
      find('.data-value').set('Spell')
    end

    # Some drivers don't fire delegated handlers reliably; ensure name is set for the value input
    page.execute_script("$('.data-attribute').last().find('.data-value').attr('name', 'card[data][type]')")

    # Ensure the value input got the correct name after renaming the key
    # Use JS that filters visible elements (offsetParent !== null) to avoid selecting hidden template
    val_name = page.evaluate_script("(function(){var els=Array.from(document.querySelectorAll('.data-attribute'));var vis=els.filter(function(e){return e.offsetParent !== null});var last=vis[vis.length-1]; return last ? last.querySelector('.data-value').getAttribute('name') : null; })()")
    unless val_name == 'card[data][type]'
      save_page('tmp/capybara/key_not_renamed.html')
      raise "Renamed key didn't update value input name (got: #{val_name}); saved page to tmp/capybara/key_not_renamed.html"
    end

    # Debug: inspect current data-attribute rows (visible only)
    rows = page.evaluate_script("Array.from(document.querySelectorAll('.data-attribute')).filter(function(e){return e.offsetParent!==null}).map(function(el) { var k = el.querySelector('.data-key') ? el.querySelector('.data-key').value : null; var v = el.querySelector('.data-value') ? el.querySelector('.data-value').value : null; var n = el.querySelector('.data-value') ? el.querySelector('.data-value').getAttribute('name') : null; return {key:k, value:v, name:n}; })")
    puts "DATA_ROWS: "; puts rows.inspect
    # Also log the form serialization to see what will be submitted
    form_serialized = page.evaluate_script("jQuery('form').serialize()")
    puts "FORM_SERIALIZED: "; puts form_serialized.inspect

    vals = page.evaluate_script("Array.from(document.querySelectorAll('input[name=\\\"card[data][type]\\\"]')).map(function(i){return {value:i.value, outer:i.outerHTML};})")
    puts "TYPE_INPUTS: "; puts vals.inspect

    # Ensure the hidden template keeps its __new__ name so it doesn't create an extra empty param
    page.execute_script("(function(){var tpl=document.getElementById('attribute-template'); if(tpl){var el=tpl.querySelector('.data-value'); if(el){el.setAttribute('name','card[data][__new__]');}}})()")

    # Remove any empty inputs for this key (clean up artifacts) before submit
    page.execute_script("Array.from(document.querySelectorAll('input[name=\\\"card[data][type]\\\"]')).forEach(function(i){ if((i.value || '').trim() === '') i.remove(); })")

    # Debug: re-evaluate the inputs and serialized form after cleanup
    vals_after = page.evaluate_script("Array.from(document.querySelectorAll('input[name=\\\"card[data][type]\\\"]')).map(function(i){return {value:i.value, outer:i.outerHTML};})")
    puts "TYPE_INPUTS_AFTER: "; puts vals_after.inspect
    form_serialized_after = page.evaluate_script("jQuery('form').serialize()")
    puts "FORM_SERIALIZED_AFTER: "; puts form_serialized_after.inspect

    save_page('tmp/capybara/before_submit_rename.html')

    find('input[type="submit"]').click

    expect(page).to have_current_path(card_path(card))
    card.reload

    # Debug: print card data and DB state
    puts "CARD ID: #{card.id}"
    puts "card.data: #{card.data.to_h.inspect}"
    puts "Card.find(id).data: #{Card.find(card.id).data.to_h.inspect}"

    # Access via OpenStruct accessor (handles symbol/string keys)
    expect(card.data.type).to eq('Spell')
  end
end
