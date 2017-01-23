class DeckCard < ApplicationRecord
  belongs_to :card
  belongs_to :deck

  validates :deck_id, :uniqueness => {:scope => :card_id}
  validates :quantity, :numericality => { :greater_than => 0, :less_than => 5 }
end
