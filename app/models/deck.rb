class Deck < ApplicationRecord
  has_many :deck_cards
  has_many :cards, :through => :deck_cards

  has_one :game_deck
  has_one :game, :through => :game_deck

  def add(card, quantity = 1)
    if dc = deck_cards.find_by(:card_id => card.id)
      dc.quantity += quantity
      dc.save
    else
      deck_cards.create(:card => card, :quantity => quantity)
    end
  end

  alias add_card add

  def total_cards
    deck_cards.sum(:quantity)
  end
end
