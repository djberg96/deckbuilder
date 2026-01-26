require 'rails_helper'

RSpec.describe Card, type: :model do
  describe 'associations' do
    it { should have_many(:deck_cards) }
    it { should have_many(:decks).through(:deck_cards) }
    it { should belong_to(:game) }
  end

  describe 'validations' do
    context 'uniqueness validation' do
      let(:game) { create(:game) }
      let!(:existing_card) { create(:card, game: game, name: 'Lightning Bolt') }

      it 'validates uniqueness of name scoped to game_id' do
        duplicate_card = build(:card, game: game, name: 'Lightning Bolt')
        expect(duplicate_card).not_to be_valid
      end

      it 'allows same name in different games' do
        other_game = create(:game)
        new_card = build(:card, game: other_game, name: 'Lightning Bolt')
        expect(new_card).to be_valid
      end
    end
  end

  describe '#add_to_deck' do
    let(:game) { create(:game) }
    let(:card) { create(:card, game: game) }
    let(:deck) { create(:deck, game: game) }

    it 'adds the card to a deck' do
      expect { card.add_to_deck(deck) }.to change(DeckCard, :count).by(1)
    end

    it 'adds the card with default quantity of 1' do
      card.add_to_deck(deck)
      deck_card = card.deck_cards.find_by(deck: deck)
      expect(deck_card.quantity).to eq(1)
    end

    it 'adds the card with specified quantity' do
      card.add_to_deck(deck, 4)
      deck_card = card.deck_cards.find_by(deck: deck)
      expect(deck_card.quantity).to eq(4)
    end
  end

  describe '#quantity' do
    let(:game) { create(:game) }
    let(:card) { create(:card, game: game) }
    let(:deck) { create(:deck, game: game) }

    it 'returns the quantity of the card in the deck' do
      create(:deck_card, card: card, deck: deck, quantity: 3)
      expect(card.quantity).to eq(3)
    end
  end

  describe '#data' do
    let(:card) { create(:card, data: { type: 'Creature', power: 5 }) }

    it 'returns data as an OpenStruct' do
      expect(card.data).to be_a(OpenStruct)
    end

    it 'allows accessing data attributes' do
      expect(card.data.type).to eq('Creature')
      expect(card.data.power).to eq(5)
    end

    context 'when stored data contains invalid keys' do
      it 'is invalid and reports the invalid keys' do
        c = Card.new(name: 'BadKeys', game: create(:game))
        # bypass setter, write raw hash to simulate legacy/malicious data
        c[:data] = { 'good' => 1, 'bad-key' => 2 }
        expect(c).not_to be_valid
        expect(c.errors[:data].join).to match(/bad-key/)
      end
    end
  end
end
