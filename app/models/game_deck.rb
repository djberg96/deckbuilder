class GameDeck < ApplicationRecord
  belongs_to :deck, :inverse_of => :game_deck
  belongs_to :game

  validates :game_id, :uniqueness => {:scope => :deck_id}
end
