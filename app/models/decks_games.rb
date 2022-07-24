class DecksGames < ApplicationRecord
  belongs_to :deck
  belongs_to :game

  validates :game_id, :uniqueness => {:scope => :deck_id}
end
