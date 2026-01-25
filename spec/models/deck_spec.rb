require 'rails_helper'

RSpec.describe Deck, type: :model do
  describe 'associations' do
    it { should have_many(:deck_cards).dependent(:destroy) }
    it { should have_many(:cards).through(:deck_cards) }
    it { should have_one(:game_deck).dependent(:destroy) }
    it { should have_one(:game).through(:game_deck) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:game_deck) }

    context 'uniqueness validation' do
      let(:user) { create(:user) }
      let!(:existing_deck) { create(:deck, user: user, name: 'My Deck') }

      it 'validates uniqueness of name scoped to user_id' do
        duplicate_deck = build(:deck, user: user, name: 'My Deck')
        expect(duplicate_deck).not_to be_valid
        expect(duplicate_deck.errors[:name]).to include('The deck name cannot be duplicated by the same user.')
      end

      it 'allows same deck name for different users' do
        other_user = create(:user)
        new_deck = build(:deck, user: other_user, name: 'My Deck')
        expect(new_deck).to be_valid
      end
    end
  end

  describe '#add' do
    let(:game) { create(:game) }
    let(:deck) { create(:deck, game: game) }
    let(:card) { create(:card, game: game) }

    it 'adds a card to the deck' do
      expect { deck.add(card) }.to change(DeckCard, :count).by(1)
    end

    it 'adds a card with default quantity of 1' do
      deck.add(card)
      deck_card = deck.deck_cards.find_by(card: card)
      expect(deck_card.quantity).to eq(1)
    end

    it 'adds a card with specified quantity' do
      deck.add(card, 3)
      deck_card = deck.deck_cards.find_by(card: card)
      expect(deck_card.quantity).to eq(3)
    end

    it 'increments quantity if card already exists in deck' do
      deck.add(card, 2)
      deck.add(card, 1)
      deck_card = deck.deck_cards.find_by(card: card)
      expect(deck_card.quantity).to eq(3)
    end
  end

  describe '#add_card' do
    let(:game) { create(:game) }
    let(:deck) { create(:deck, game: game) }
    let(:card) { create(:card, game: game) }

    it 'is an alias for #add' do
      expect(deck.method(:add_card)).to eq(deck.method(:add))
    end
  end

  describe '#delete_card' do
    let(:game) { create(:game) }
    let(:deck) { create(:deck, game: game) }
    let(:card) { create(:card, game: game) }

    before do
      deck.add(card, 3)
    end

    it 'decrements the quantity of a card in the deck' do
      deck.delete_card(card, 1)
      deck_card = deck.deck_cards.find_by(card: card)
      expect(deck_card.quantity).to eq(2)
    end

    it 'decrements by specified quantity' do
      deck.delete_card(card, 2)
      deck_card = deck.deck_cards.find_by(card: card)
      expect(deck_card.quantity).to eq(1)
    end
  end

  describe '#total_cards' do
    let(:game) { create(:game) }
    let(:deck) { create(:deck, game: game) }

    it 'returns 0 when no cards are in the deck' do
      expect(deck.total_cards).to eq(0)
    end

    it 'sums the quantity of all cards in the deck' do
      card1 = create(:card, game: game)
      card2 = create(:card, game: game)
      deck.add(card1, 2)
      deck.add(card2, 3)
      expect(deck.total_cards).to eq(5)
    end
  end

  describe '#legal?' do
    let(:game) { create(:game, minimum_cards_per_deck: 40, maximum_cards_per_deck: 60, maximum_individual_cards: 4) }
    let(:deck) { create(:deck, game: game) }

    context 'when deck meets all requirements' do
      it 'returns true' do
        card = create(:card, game: game)
        45.times { deck.add(create(:card, game: game), 1) }
        expect(deck.legal?).to be true
      end
    end

    context 'when deck has too few cards' do
      it 'returns false' do
        card = create(:card, game: game)
        deck.add(card, 2)
        deck.reload
        expect(deck.legal?).to be false
      end
    end

    context 'when deck has too many cards' do
      it 'returns false' do
        70.times { deck.add(create(:card, game: game), 1) }
        deck.reload
        expect(deck.legal?).to be false
      end
    end

    context 'when deck has too many of a single card' do
      it 'returns false' do
        card = create(:card, game: game)
        deck.add(card, 4)
        deck_card = deck.deck_cards.find_by(card: card)
        deck_card.update_column(:quantity, 5) # Bypass validation
        40.times { deck.add(create(:card, game: game), 1) }
        deck.reload
        expect(deck.legal?).to be false
      end
    end
  end

  describe '#inspect' do
    let(:game) { create(:game, name: 'Magic: The Gathering') }
    let(:user) { create(:user, username: 'testuser') }
    let(:deck) { create(:deck, :with_game, game: game, user: user, name: 'Test Deck', description: 'A test deck', private: false) }

    it 'returns a formatted string with deck information' do
      card = create(:card, game: game, name: 'Lightning Bolt')
      deck.add(card, 4)

      result = deck.inspect
      expect(result).to include('Test Deck')
      expect(result).to include('A test deck')
      expect(result).to include('testuser')
      expect(result).to include('Magic: The Gathering')
      expect(result).to include('Lightning Bolt')
    end
  end
end
