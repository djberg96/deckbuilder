require 'rails_helper'

RSpec.describe 'Card image resize auto-flow', type: :system do
  before do
    driven_by :selenium_firefox_headless
  end

  it 'offers to resize oversized images and submits resized image successfully', js: true do
    user = create(:user, username: 'resizer', password: 'password123')
    login_as(user)

    create(:game, name: 'G1', edition: 'E1', minimum_cards_per_deck: 10, maximum_cards_per_deck: 60, maximum_individual_cards: 4)
    visit new_card_path

    fill_in 'Name', with: 'Resize Card'
    fill_in 'Description', with: 'Auto-resize image test'
    select 'G1 (E1)', from: 'Game'

    # Generate a large PNG blob client-side and attach it to the file input.
    # Accept the confirm dialog that offers to resize automatically.
    accept_confirm do
      page.execute_script(<<~JS)
        (function(){
          var canvas = document.createElement('canvas');
          canvas.width = 2000; canvas.height = 2000;
          var ctx = canvas.getContext('2d');
          ctx.fillStyle = 'red'; ctx.fillRect(0,0,canvas.width, canvas.height);
          canvas.toBlob(function(b) {
            var f = new File([b], 'big.png', {type: 'image/png'});
            var dt = new DataTransfer();
            dt.items.add(f);
            var input = document.querySelector('input[name="card[new_images][]"]');
            input.files = dt.files;
            input.dispatchEvent(new Event('change', {bubbles:true}));
          }, 'image/png', 1.0);
        })();
      JS
    end

    # wait for the file to be resized and the error cleared
    expect(page).to have_no_content(/exceed/)

    click_button 'Create Card'

    # Wait for create and ensure card created with at least one image <= 64 KB
    expect(Card.count).to eq(1)
    c = Card.first
    expect(c.card_images.count).to be >= 1
    expect(c.card_images.first.data.bytesize).to be <= (64 * 1024)
  end
end
