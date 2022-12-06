class Deck < ApplicationRecord
  include FieldSanitizer

  has_many :deck_cards
  has_many :cards, :through => :deck_cards

  has_one :game_deck
  has_one :game, :through => :game_deck

  belongs_to :user

  validates :name,
    :presence   => true,
    :uniqueness => {
      :scope   => :user_id,
      :message => "The deck name cannot be duplicated by the same user."
    }

  autostrip :description
  autostrip_and_validate :name

  def add(card, quantity = 1)
    if dc = deck_cards.find_by(:card_id => card.id)
      dc.quantity += quantity
      dc.save
    else
      deck_cards.create(:card => card, :quantity => quantity)
    end
  end

  alias add_card add

  def total_cards
    deck_cards.sum(:quantity)
  end

  def legal?
    bool = true

    if game
      bool = false if game.minimum_cards_per_deck and total_cards <= game.minimum_cards_per_deck
      bool = false if game.maximum_cards_per_deck and total_cards >= game.maximum_cards_per_deck
      bool = false if game.maximum_individual_cards and cards.any?{ |card| card.quantity > game.maximum_individual_cards }
    end

    bool
  end
end
