require 'rails_helper'

RSpec.describe "decks/new", type: :view do
  before(:each) do
    assign(:deck, Deck.new())
  end

  it "renders new deck form" do
    render

    assert_select "form[action=?][method=?]", decks_path, "post" do
    end
  end
end
