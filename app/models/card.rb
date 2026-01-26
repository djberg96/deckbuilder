class Card < ApplicationRecord
  has_many :deck_cards
  has_many :decks, :through => :deck_cards
  belongs_to :game

  validates :name, :uniqueness => {:scope => :game_id}

  # Ensure stored data keys are alphanumeric only (letters and numbers)
  validate :data_keys_format

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
    # remove placeholder/new keys, blank keys, and non-alphanumeric keys (letters+numbers only)
    h = h.transform_keys(&:to_s).reject do |k, _|
      k.strip.empty? || k.match?(/\A(__new__|new_)/i) || !k.match?(/\A[A-Za-z0-9]+\z/)
    end
    self[:data] = h
    @data_struct = OpenStruct.new(h)
  end

  private

  def data_keys_format
    return unless self[:data].is_a?(Hash)
    invalid = self[:data].keys.select { |k| !(k =~ /\A[A-Za-z0-9]+\z/) }
    if invalid.any?
      errors.add(:data, "contains invalid keys: #{invalid.join(', ')}")
    end
  end
end
