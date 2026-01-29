class Card < ApplicationRecord
  has_many :deck_cards
  has_many :decks, :through => :deck_cards

  # images stored separately in card_images table
  has_many :card_images, dependent: :destroy

  belongs_to :game

  validates :name, :uniqueness => {:scope => :game_id}

  # Ensure stored data keys are ASCII only
  validate :data_keys_format

  # Ensure no data attribute value exceeds 512 characters
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

    # record invalid keys (before we silently drop them) so validation can report them
    # allow ASCII characters for keys (spaces allowed)
    @data_invalid_keys = normalized.keys.select { |k| !k.match?( /\A[[:ascii:]]+\z/ ) }

    # remove placeholder/new keys, blank keys, and keys that contain non-ASCII characters
    filtered = normalized.reject do |k, _|
      k.strip.empty? || k.match?(/\A(__new__|new_)/i) || !k.match?( /\A[[:ascii:]]+\z/ )
    end

    self[:data] = filtered
    @data_struct = OpenStruct.new(filtered)
  end

  private

  def data_keys_format
    invalid = []
    # include any invalid keys recorded by the setter (keys that were dropped)
    invalid += @data_invalid_keys if defined?(@data_invalid_keys) && @data_invalid_keys.any?

    # also check persisted/raw hash keys if present
    if self[:data].is_a?(Hash)
      # consider keys invalid when they contain non-ASCII characters
      invalid += self[:data].keys.select { |k| k.to_s !~ /[[:ascii:]]/ }
    end

    invalid.uniq!
    if invalid.any?
      errors.add(:data, "contains invalid keys: #{invalid.join(', ')}")
    end
  end

  def data_values_length
    return unless self[:data].is_a?(Hash)
    too_long = self[:data].select { |_, v| v.to_s.length > 512 }.keys
    if too_long.any?
      errors.add(:data, "contains values longer than 512 characters: #{too_long.join(', ')}")
    end
  end
end
