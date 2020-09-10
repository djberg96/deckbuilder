class Game < ApplicationRecord
  has_many :game_decks
  has_many :decks, :through => :game_decks

  def add_deck(deck, quantity = 1)
    game_decks.create(:deck => deck, :quantity => quantity)
  end

  def total_cards
    game_decks.sum(:quantity)
  end
end
