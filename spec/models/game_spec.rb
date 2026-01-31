require 'rails_helper'

RSpec.describe Game, type: :model do
  describe 'associations' do
    it { should have_many(:game_decks) }
    it { should have_many(:decks).through(:game_decks) }
    it { should have_many(:cards) }
  end

  describe 'validations' do
    it 'validates presence of name' do
      game = build(:game, name: '')
      expect(game).not_to be_valid
      expect(game.errors[:name]).to include("can't be blank")
    end

    it 'validates numericality of maximum_individual_cards' do
      game = build(:game, maximum_individual_cards: -1)
      expect(game).not_to be_valid
      expect(game.errors[:maximum_individual_cards]).to be_present
    end

    it 'validates minimum_cards_per_deck is at least 10' do
      game = build(:game, minimum_cards_per_deck: 5)
      expect(game).not_to be_valid
      expect(game.errors[:minimum_cards_per_deck]).to be_present
    end

    it 'allows minimum_cards_per_deck equal to 10' do
      game = build(:game, minimum_cards_per_deck: 10)
      expect(game).to be_valid
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

    it 'does not create duplicate association rows when called multiple times' do
      game.add_deck(deck)
      game.add_deck(deck)
      expect(game.game_decks.count).to eq(1)
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
      game.add_deck(deck1)
      game.add_deck(deck2)
      expect(game.total_decks).to eq(2)
    end
  end
end
