require 'rails_helper'

RSpec.describe DecksController, type: :controller do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:valid_attributes) { { name: 'Test Deck', description: 'A test deck', private: false, game_deck_attributes: { game_id: game.id } } }
  let(:invalid_attributes) { { name: '' } }

  before do
    session[:user_id] = user.id
  end

  describe 'GET #index' do
    it 'returns a success response' do
      deck = create(:deck, user: user)
      get :index
      expect(response).to be_successful
    end

    it 'assigns all decks as @decks' do
      deck = create(:deck, user: user)
      get :index
      expect(assigns(:decks)).to eq([deck])
    end

    it 'shows game name and edition in separate columns on index when present' do
      game = create(:game, edition: 'Limited')
      deck = create(:deck, user: user, game: game)
      get :index
      expect(response.body).to include(game.name)
      expect(response.body).to include(game.edition)
    end

    it 'includes game name/edition in the filter dropdown' do
      game = create(:game, edition: 'Limited')
      deck = create(:deck, user: user, game: game)
      get :index
      # the filter select options include the game display value (Name / Edition)
      expect(response.body).to match(/<option\s+value="#{game.id}"[^>]*>\s*#{Regexp.escape(game.name)}\s*\/\s*#{Regexp.escape(game.edition)}\s*<\/:?option>/i)
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      deck = create(:deck, user: user)
      get :show, params: { id: deck.to_param }
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      deck = create(:deck, user: user)
      get :edit, params: { id: deck.to_param }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Deck' do
        expect {
          post :create, params: { deck: valid_attributes }
        }.to change(Deck, :count).by(1)
      end

      it 'assigns the current user to the deck' do
        post :create, params: { deck: valid_attributes }
        expect(Deck.last.user_id).to eq(user.id)
      end

      it 'redirects to the created deck' do
        post :create, params: { deck: valid_attributes }
        expect(response).to redirect_to(Deck.last)
      end

      it 'ignores blank nested deck_card entries when creating via controller' do
        card = create(:card, game: game)
        params = valid_attributes.merge(deck_cards_attributes: { '0' => { 'card_id' => card.id, 'quantity' => 2 }, '1' => { 'card_id' => '', 'quantity' => 1 } })
        expect {
          post :create, params: { deck: params }
        }.to change(Deck, :count).by(1)
        deck = Deck.last
        expect(deck.deck_cards.size).to eq(1)
        expect(deck.deck_cards.first.card_id).to eq(card.id)
      end
    end

    context 'with invalid params' do
      it 'returns a success response (i.e. to display the new template)' do
        post :create, params: { deck: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { { name: 'Updated Deck' } }

      it 'updates the requested deck' do
        deck = create(:deck, user: user)
        put :update, params: { id: deck.to_param, deck: new_attributes }
        deck.reload
        expect(deck.name).to eq('Updated Deck')
      end

      it 'removes nested deck_cards when _destroy is set' do
        # prepare deck with a persisted deck card
        deck = create(:deck, user: user)
        deck.build_game_deck(game: game)
        deck.save!
        c = create(:card, game: game)
        dc = deck.deck_cards.create!(card: c, quantity: 1)

        params = valid_attributes.merge(deck_cards_attributes: { '0' => { 'id' => dc.id, '_destroy' => '1' } })
        put :update, params: { id: deck.to_param, deck: params }
        deck.reload
        expect(deck.deck_cards).to be_empty
      end

      it 'redirects to the deck' do
        deck = create(:deck, user: user)
        put :update, params: { id: deck.to_param, deck: valid_attributes }
        expect(response).to redirect_to(deck)
      end
    end

    context 'with invalid params' do
      it 'returns a success response (i.e. to display the edit template)' do
        deck = create(:deck, user: user)
        put :update, params: { id: deck.to_param, deck: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested deck' do
      deck = create(:deck, user: user)
      expect {
        delete :destroy, params: { id: deck.to_param }
      }.to change(Deck, :count).by(-1)
    end

    it 'redirects to the decks list' do
      deck = create(:deck, user: user)
      delete :destroy, params: { id: deck.to_param }
      expect(response).to redirect_to(decks_url)
    end
  end
end
