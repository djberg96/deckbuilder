require 'rails_helper'

RSpec.describe 'cards/show.html.erb', type: :view do
  it 'shows associated images as data URLs and uses two-column layout' do
    card = create(:card, description: 'Nice card')
    card.card_images.create!(filename: 'small.png', content_type: 'image/png', data: File.binread(Rails.root.join('spec/fixtures/small.png')))

    assign(:card, card)
    render

    expect(rendered).to match(/data:image\/png;base64,/)
    expect(rendered).to match(/Description:.*Nice card/m)
    expect(rendered).to match(/class="row"/)
    # ensure Details header appears after the main block
    expect(rendered.index('Details')).to be > rendered.index('Description:')
  end
end
