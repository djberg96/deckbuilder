class Card < ApplicationRecord
  has_many :deck_cards, dependent: :destroy
  has_many :decks, :through => :deck_cards
  belongs_to :game

  # Remove Active Storage attachment
  # has_one_attached :image

  delegate_missing_to :data

  validates :name, :uniqueness => {:scope => :game_id}

  # Handle image data storage in database
  attr_accessor :image_file

  def image_file=(uploaded_file)
    if uploaded_file.present?
      self.image_data = uploaded_file.read
      self.image_content_type = uploaded_file.content_type
      self.image_filename = uploaded_file.original_filename
    end
  end

  def has_image?
    image_data.present?
  end

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
