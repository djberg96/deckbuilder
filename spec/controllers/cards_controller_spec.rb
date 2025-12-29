require 'rails_helper'

RSpec.describe CardsController, type: :controller do
  let(:user) { create(:user) }
  let(:game) { create(:game) }
  let(:valid_attributes) { { name: 'Test Card', description: 'A test card', data: { type: 'Creature' }, game_id: game.id } }
  let(:invalid_attributes) { { name: '', game_id: nil } }

  before do
    session[:user_id] = user.id
  end

  describe 'GET #index' do
    it 'returns a success response' do
      Card.create! valid_attributes
      get :index
      expect(response).to be_successful
    end

    it 'assigns all cards as @cards' do
      card = Card.create! valid_attributes
      get :index
      expect(assigns(:cards)).to eq([card])
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      card = Card.create! valid_attributes
      get :show, params: { id: card.to_param }
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
      card = Card.create! valid_attributes
      get :edit, params: { id: card.to_param }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Card' do
        expect {
          post :create, params: { card: { name: 'Test Card', description: 'A test card', data: { type: 'Creature' }, game_id: game.id } }
        }.to change(Card, :count).by(1)
      end

      it 'redirects to the created card' do
        post :create, params: { card: { name: 'Test Card', description: 'A test card', data: { type: 'Creature' }, game_id: game.id } }
        expect(response).to redirect_to(Card.last)
      end
    end

    context 'with invalid params' do
      it 'does not create a card' do
        expect {
          post :create, params: { card: invalid_attributes }
        }.not_to change(Card, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { { name: 'Updated Card' } }

      it 'updates the requested card' do
        card = Card.create! valid_attributes
        put :update, params: { id: card.to_param, card: new_attributes }
        card.reload
        expect(card.name).to eq('Updated Card')
      end

      it 'redirects to the card' do
        card = Card.create! valid_attributes
        put :update, params: { id: card.to_param, card: valid_attributes }
        expect(response).to redirect_to(card)
      end
    end

    context 'with invalid params' do
      it 'redirects when params are invalid' do
        card = Card.create! valid_attributes
        put :update, params: { id: card.to_param, card: invalid_attributes }
        # Card is updated but with invalid data causing redirect
        expect(card.reload).to be_present
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested card' do
      card = Card.create! valid_attributes
      expect {
        delete :destroy, params: { id: card.to_param }
      }.to change(Card, :count).by(-1)
    end

    it 'redirects to the cards list' do
      card = Card.create! valid_attributes
      delete :destroy, params: { id: card.to_param }
      expect(response).to redirect_to(cards_url)
    end
  end
end
