class DeckCard < ApplicationRecord
  belongs_to :card
  belongs_to :deck

  validates :deck_id, :uniqueness => {:scope => :card_id}
end
