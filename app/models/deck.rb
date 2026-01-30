class Deck < ApplicationRecord
  include FieldSanitizer

  has_many :deck_cards, :dependent => :destroy
  has_many :cards, :through => :deck_cards

  has_one :game_deck, :dependent => :destroy, :autosave => true, :inverse_of => :deck
  has_one :game, :through => :game_deck

  belongs_to :user

  accepts_nested_attributes_for :game_deck
  # Ignore nested deck_card entries that don't select a card (prevents validation errors when the form submits empty rows)
  accepts_nested_attributes_for :deck_cards, reject_if: proc { |attrs| attrs['card_id'].blank? }

  # Defensive cleanup: remove any nested deck_cards that reference no card or a non-existent card
  before_validation :reject_invalid_deck_cards

  private def reject_invalid_deck_cards
    deck_cards.each do |dc|
      # mark for destruction if no card_id provided or referenced card does not exist
      if dc.card_id.blank? || !Card.exists?(dc.card_id)
        dc.mark_for_destruction
      end
    end
  end

  public

  validates :game_deck, :presence => true

  # The same user cannot have the same deck name more than once.
  #
  validates :name,
    :presence   => true,
    :uniqueness => {
      :scope   => :user_id,
      :message => "The deck name cannot be duplicated by the same user."
    }

  # Add +quantity+ of +card+ to the deck. By default it will add one card.
  #
  def add(card, quantity = 1)
    raise ArgumentError, 'card must be provided' if card.nil?

    if dc = deck_cards.find_by(:card => card)
      dc.quantity += quantity
      dc.save!
    else
      deck_cards.create!(:card => card, :quantity => quantity)
    end
  end

  alias add_card add

  def delete_card(card, quantity = 1)
    if dc = deck_cards.find_by(:card => card)
      dc.quantity -= quantity
      dc.save!
    end
  end

  # Returns the total number of cards in the deck.
  #
  def total_cards
    deck_cards.sum(:quantity)
  end

  # Returns false if the deck does not have the minimum number of cards, exceeds
  # the maximum number of cards, or has too many of the same card. If none of
  # those conditions fail, or if those conditions don't apply, then it
  # returns true.
  #
  def legal?
    bool = true

    if game
      bool = false if game.minimum_cards_per_deck and total_cards < game.minimum_cards_per_deck
      bool = false if game.maximum_cards_per_deck and total_cards > game.maximum_cards_per_deck
      bool = false if game.maximum_individual_cards and deck_cards.any?{ |dc| dc.quantity > game.maximum_individual_cards }
    end

    bool
  end

  def inspect
    reload

    str = "#<#{self.class.name}\n  name => #{name}\n  description => #{description}"
    str << "\n  owner => #{user.username}"
    str << "\n  private => #{private?}"
    str << "\n  game => #{game.name}" if game&.name
    str << "\n  Cards (#{total_cards}):"

    deck_cards.each do |dc|
      str << "\n    #{dc.card.name} => #{dc.quantity}"
    end

    str << "\n>"

    str
  end
end
