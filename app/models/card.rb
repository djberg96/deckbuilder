class Card < ApplicationRecord
  has_many :deck_cards
  has_many :decks, :through => :deck_cards

  serialize :data
  delegate_missing_to :data

  def add_to_deck(deck, quantity = 1)
    deck_cards.create(:card => self, :deck => deck, :quantity => quantity)
  end

  def quantity
    deck_cards.find(self.id).quantity
  end

  def data
    @data ||= OpenStruct.new(self[:data])
  end
end
