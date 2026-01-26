require 'rails_helper'

RSpec.describe 'cards/show.html.erb', type: :view do
  it 'shows associated images as data URLs' do
    card = create(:card)
    card.card_images.create!(filename: 'small.png', content_type: 'image/png', data: File.binread(Rails.root.join('spec/fixtures/small.png')))

    assign(:card, card)
    render

    expect(rendered).to match(/data:image\/png;base64,/)
  end
end
