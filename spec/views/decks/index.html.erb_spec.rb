require 'rails_helper'

RSpec.describe "decks/index", type: :view do
  before(:each) do
    assign(:decks, [
      Deck.create!(),
      Deck.create!()
    ])
  end

  it "renders a list of decks" do
    render
  end
end
