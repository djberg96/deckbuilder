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
    end

    context 'with invalid params' do
      it 'returns a success response (i.e. to display the new template)' do
        post :create, params: { deck: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
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
        expect(response).to have_http_status(:unprocessable_entity)
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
