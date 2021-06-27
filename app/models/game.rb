class Game < ApplicationRecord
  has_many :game_decks
  has_many :decks, :through => :game_decks
  has_many :cards

  def add_deck(deck, quantity = 1)
    game_decks.create(:deck => deck, :quantity => quantity)
  end

  def total_decks
    game_decks.sum(:quantity)
  end
end
