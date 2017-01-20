class Card < ApplicationRecord
  has_many :deck_cards
  has_many :decks, :through => :deck_cards
end
