class Card < ApplicationRecord
  has_many :deck_cards
  has_many :decks, :through => :deck_cards, dependent: :restrict_with_exception

  # images stored separately in card_images table
  has_many :card_images, dependent: :destroy

  belongs_to :game

  validates :name, :uniqueness => {:scope => :game_id}

  # Ensure stored data keys are alphanumeric only (letters and numbers)
  validate :data_keys_format

  # Ensure no data attribute value exceeds 128 characters
  validate :data_values_length

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
    # normalize keys: stringify, strip, and scrunch multiple spaces to single space
    normalized = h.transform_keys(&:to_s).map do |k, v|
      nk = k.to_s.strip.gsub(/ {2,}/, ' ') # collapse consecutive spaces into one
      [nk, v]
    end.to_h

    # remove placeholder/new keys, blank keys, and keys that contain characters other than letters, numbers, or single spaces
    filtered = normalized.reject do |k, _|
      k.strip.empty? || k.match?(/\A(__new__|new_)/i) || !k.match?(/\A[A-Za-z0-9 ]+\z/)
    end

    self[:data] = filtered
    @data_struct = OpenStruct.new(filtered)
  end

  private

  def data_keys_format
    return unless self[:data].is_a?(Hash)
    invalid = self[:data].keys.select { |k| !(k =~ /\A[A-Za-z0-9 ]+\z/) }
    if invalid.any?
      errors.add(:data, "contains invalid keys: #{invalid.join(', ')}")
    end
  end

  def data_values_length
    return unless self[:data].is_a?(Hash)
    too_long = self[:data].select { |_, v| v.to_s.length > 128 }.keys
    if too_long.any?
      errors.add(:data, "contains values longer than 128 characters: #{too_long.join(', ')}")
    end
  end
end
