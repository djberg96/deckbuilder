class Deck < ApplicationRecord
  has_many :cards_decks
  has_many :cards, :through => :cards_decks

  has_one :game_deck
  has_one :game, :through => :game_deck

  belongs_to :user

  validates :name,
    :presence => true,
    :uniqueness => {
      :scope   => :user_id,
      :message => "The deck name cannot be duplicated by the same user."
    }

  def add(card, quantity = 1)
    if cd = cards_decks.find_by(:card_id => card.id)
      cd.quantity += quantity
      cd.save
    else
      cards_decks.create(:card => card, :quantity => quantity)
    end
  end

  alias add_card add

  def total_cards
    cards_decks.sum(:quantity)
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
