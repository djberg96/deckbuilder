class Card < ApplicationRecord
  has_many :deck_cards
  has_many :decks, :through => :deck_cards

  def add_to_deck(deck, quantity = 1)
    deck_cards.create(:card => self, :deck => deck, :quantity => quantity)
  end
end
