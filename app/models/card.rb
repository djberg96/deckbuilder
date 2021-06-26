class Card < ApplicationRecord
  has_many :deck_cards
  has_many :decks, :through => :deck_cards

  serialize :data
  delegate_missing_to :data

  # Add cards to the specified deck. If no quantity is specified, then one
  # is the default.
  #
  def add_to_deck(deck, quantity = 1)
    deck_cards.create(:card => self, :deck => deck, :quantity => quantity)
  end

  # Find the quantity of a given card for the current deck.
  #
  def quantity
    deck_cards.find_by(:card_id => self.id).quantity
  end

  # Return the JSON data as an openstruct object.
  #
  def data
    @data ||= OpenStruct.new(self[:data])
  end
end
