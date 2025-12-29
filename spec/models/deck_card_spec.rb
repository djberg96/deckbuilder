require 'rails_helper'

RSpec.describe DeckCard, type: :model do
  describe 'associations' do
    it { should belong_to(:card) }
    it { should belong_to(:deck) }
  end

  describe 'validations' do
    context 'uniqueness validation' do
      let(:game) { create(:game) }
      let(:deck) { create(:deck, :with_game, game: game) }
      let(:card) { create(:card, game: game) }
      let!(:existing_deck_card) { create(:deck_card, deck: deck, card: card) }

      it 'validates uniqueness of deck_id scoped to card_id' do
        duplicate = build(:deck_card, deck: deck, card: card)
        expect(duplicate).not_to be_valid
      end

      it 'allows same card in different decks' do
        other_deck = create(:deck, :with_game, game: game)
        new_deck_card = build(:deck_card, deck: other_deck, card: card)
        expect(new_deck_card).to be_valid
      end
    end

    context 'card_limits validation' do
      let(:game) { create(:game, maximum_individual_cards: 4) }
      let(:deck) { create(:deck, :with_game, game: game) }
      let(:card) { create(:card, game: game) }

      it 'is invalid when quantity is 0' do
        deck_card = build(:deck_card, deck: deck, card: card, quantity: 0)
        expect(deck_card).not_to be_valid
        expect(deck_card.errors[:quantity]).to include('must be between 1 and 4')
      end

      it 'is invalid when quantity exceeds maximum_individual_cards' do
        deck_card = build(:deck_card, deck: deck, card: card, quantity: 5)
        expect(deck_card).not_to be_valid
        expect(deck_card.errors[:quantity]).to include('must be between 1 and 4')
      end

      it 'is valid when quantity is within limits' do
        deck_card = build(:deck_card, deck: deck, card: card, quantity: 4)
        expect(deck_card).to be_valid
      end

      it 'skips validation when quantity, deck, or game is blank' do
        deck_card = DeckCard.new(card: card, quantity: 10)
        deck_card.valid?
        expect(deck_card.errors[:quantity]).to be_empty
      end
    end
  end
end
