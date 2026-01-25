require 'rails_helper'

RSpec.describe GameDeck, type: :model do
  describe 'associations' do
    it { should belong_to(:deck) }
    it { should belong_to(:game) }
  end

  describe 'validations' do
    context 'uniqueness validation' do
      let(:game) { create(:game) }
      let(:deck) { create(:deck) }
      let!(:existing_game_deck) { create(:game_deck, game: game, deck: deck) }

      it 'validates uniqueness of game_id scoped to deck_id' do
        duplicate = build(:game_deck, game: game, deck: deck)
        expect(duplicate).not_to be_valid
      end

      it 'allows same game with different deck' do
        other_deck = create(:deck)
        new_game_deck = build(:game_deck, game: game, deck: other_deck)
        expect(new_game_deck).to be_valid
      end
    end
  end
end
