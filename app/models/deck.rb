class Deck < ApplicationRecord
  has_many :deck_cards
  has_many :cards, :through => :deck_cards

  def add(card, quantity = 1)
    deck_cards.create(:card => card, :quantity => quantity)
  end
end
