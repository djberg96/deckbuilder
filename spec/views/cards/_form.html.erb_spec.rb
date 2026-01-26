require 'rails_helper'

RSpec.describe 'cards/_form.html.erb', type: :view do
  it 'shows Add Image? and centered file input when no images exist' do
    card = build(:card)
    assign(:card, card)
    render partial: 'cards/form', locals: { card: card }

    expect(rendered).to match(/Add Image\?/)    
    expect(rendered).to match(/card\[new_images\]\[\]/)
  end
end
