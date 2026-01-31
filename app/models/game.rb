class Game < ApplicationRecord
  has_many :game_decks
  has_many :decks, :through => :game_decks
  has_many :cards

  validates :maximum_individual_cards,
    :numericality => {
      :only_integer                 => true,
      :greater_than                 => 0,
      :less_than_or_equal_to        => :maximum_cards_per_deck,
    },
    :allow_nil => true

  # name is required for games
  validates :name, presence: true
  validates :name, uniqueness: {scope: :edition, message: "Game/Edition already exists"}

  def add_deck(deck)
    # Ensure a single association row per deck/game.
    game_decks.find_or_create_by(deck: deck)
  end

  def total_decks
    # Count distinct associated decks (exclude malformed rows with no deck_id)
    game_decks.where.not(deck_id: nil).count
  end
end
