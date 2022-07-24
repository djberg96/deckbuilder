require 'rails_helper'

RSpec.describe "decks/show", type: :view do
  before(:each) do
    @deck = assign(:deck, Deck.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
