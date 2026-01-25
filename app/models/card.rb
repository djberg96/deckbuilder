class Card < ApplicationRecord
  has_many :deck_cards
  has_many :decks, :through => :deck_cards
  belongs_to :game

  validates :name, :uniqueness => {:scope => :game_id}

  def add_to_deck(deck, quantity = 1)
    deck_cards.create(:card => self, :deck => deck, :quantity => quantity)
  end

  def quantity
    deck_cards.find_by(:card_id => self.id).quantity
  end

  # Return the JSON data as an OpenStruct for convenient access
  def data
    h = self[:data].is_a?(Hash) ? self[:data] : (self[:data].present? ? JSON.parse(self[:data]) : {})
    @data_struct = OpenStruct.new(h)
  end

  def data=(value)
    h = value.is_a?(Hash) ? value : (value.present? ? JSON.parse(value) : {})
    # remove placeholder/new keys and blank keys
    h = h.transform_keys(&:to_s).reject { |k, _| k.strip.empty? || k.match?(/\A(__new__|new_)/i) }
    self[:data] = h
    @data_struct = OpenStruct.new(h)
  end
end
