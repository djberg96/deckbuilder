require 'rails_helper'

RSpec.describe Game, type: :model do
  describe 'associations' do
    it { should have_many(:game_decks) }
    it { should have_many(:decks).through(:game_decks) }
    it { should have_many(:cards) }
  end

  describe 'validations' do
    it 'validates numericality of maximum_individual_cards' do
      game = build(:game, maximum_individual_cards: -1)
      expect(game).not_to be_valid
      expect(game.errors[:maximum_individual_cards]).to be_present
    end

    context 'uniqueness validation' do
      let!(:existing_game) { create(:game, name: 'Magic', edition: '2023') }

      it 'validates uniqueness of name scoped to edition' do
        duplicate_game = build(:game, name: 'Magic', edition: '2023')
        expect(duplicate_game).not_to be_valid
        expect(duplicate_game.errors[:name]).to include('Game/Edition already exists')
      end

      it 'allows same name with different edition' do
        new_game = build(:game, name: 'Magic', edition: '2024')
        expect(new_game).to be_valid
      end
    end
  end

  describe '#add_deck' do
    let(:game) { create(:game) }
    let(:deck) { create(:deck, game: game) }

    it 'adds a deck to the game' do
      expect { game.add_deck(deck) }.to change(GameDeck, :count).by(1)
    end

    it 'adds a deck with specified quantity' do
      game.add_deck(deck, 3)
      game_deck = game.game_decks.last
      expect(game_deck).to be_present
      expect(game_deck.quantity).to eq(3)
    end

    it 'increments quantity when adding the same deck multiple times' do
      game.add_deck(deck, 2)
      game.add_deck(deck, 3)
      gd = game.game_decks.find_by(deck: deck)
      expect(gd.quantity).to eq(5)
    end
  end

  describe '#total_decks' do
    let(:game) { create(:game) }

    it 'returns 0 when no decks are associated' do
      expect(game.total_decks).to eq(0)
    end

    it 'counts all associated decks' do
      deck1 = create(:deck)
      deck2 = create(:deck)
      game.add_deck(deck1, 2)
      game.add_deck(deck2, 3)
      expect(game.game_decks.count).to eq(2)
    end
  end
end
