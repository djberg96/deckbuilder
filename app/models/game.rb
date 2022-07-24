class Game < ApplicationRecord
  has_many :decks_games
  has_many :decks, :through => :decks_games
  has_many :cards

  validates :maximum_individual_cards,
    :numericality => {
      :only_integer          => true,
      :greater_than          => 0,
      :less_than_or_equal_to => :minimum_cards_per_deck,
    }

  def add_deck(deck, quantity = 1)
    game_decks.create(:deck => deck, :quantity => quantity)
  end

  def total_decks
    game_decks.sum(:quantity)
  end
end
