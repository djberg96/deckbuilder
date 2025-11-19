class DeckCard < ApplicationRecord
  belongs_to :card
  belongs_to :deck

  validates :deck_id, :uniqueness => {:scope => :card_id}
  validate :card_limits

  private

  # Validate that the quantity of this card in the deck does not exceed
  # the maximum allowed for the game.
  def card_limits
    return if quantity.blank? || deck.blank? || deck.game.blank?

    max_cards = deck.game.maximum_individual_cards

    if quantity <= 0 || quantity > max_cards
      errors.add(:quantity, "must be between 1 and #{max_cards}")
    end
  end
end
