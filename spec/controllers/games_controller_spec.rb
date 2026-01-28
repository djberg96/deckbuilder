require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) {
    {
      name: 'Magic: The Gathering',
      edition: '2023',
      description: 'A card game',
      minimum_cards_per_deck: 40,
      maximum_cards_per_deck: 60,
      maximum_individual_cards: 4
    }
  }
  let(:invalid_attributes) { { name: '', maximum_individual_cards: -1 } }

  before do
    session[:user_id] = user.id
  end

  describe 'GET #index' do
    it 'returns a success response' do
      Game.create! valid_attributes
      get :index
      expect(response).to be_successful
    end

    it 'assigns all games as @games' do
      game = Game.create! valid_attributes
      get :index
      expect(assigns(:games).map(&:id)).to include(game.id)
    end

    it 'includes deck counts for games' do
      game = Game.create! valid_attributes
      create(:deck, game: game)
      get :index
      # the controller selects decks_count as an attribute; ensure it's present
      expect(assigns(:games).detect { |g| g.id == game.id }.respond_to?(:decks_count)).to be true
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      game = Game.create! valid_attributes
      get :show, params: { id: game.to_param }
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
      game = Game.create! valid_attributes
      get :edit, params: { id: game.to_param }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Game' do
        expect {
          post :create, params: { game: valid_attributes }
        }.to change(Game, :count).by(1)
      end

      it 'redirects to the created game' do
        post :create, params: { game: valid_attributes }
        expect(response).to redirect_to(Game.last)
      end
    end

    context 'with invalid params' do
      it 'does not create a game' do
        expect {
          post :create, params: { game: { name: '' } }
        }.not_to change(Game, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { { description: 'Updated description' } }

      it 'updates the requested game' do
        game = Game.create! valid_attributes
        put :update, params: { id: game.to_param, game: new_attributes }
        game.reload
        expect(game.description).to eq('Updated description')
      end

      it 'updates the edition when supplied' do
        game = Game.create! valid_attributes.merge(edition: '2021')
        put :update, params: { id: game.to_param, game: { edition: '2025' } }
        game.reload
        expect(game.edition).to eq('2025')
      end

      it 'redirects to the game' do
        game = Game.create! valid_attributes
        put :update, params: { id: game.to_param, game: valid_attributes }
        expect(response).to redirect_to(game)
      end
    end

    context 'with invalid params' do
      it 'returns a success response (i.e. to display the edit template)' do
        game = Game.create! valid_attributes
        put :update, params: { id: game.to_param, game: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested game' do
      game = Game.create! valid_attributes
      expect {
        delete :destroy, params: { id: game.to_param }
      }.to change(Game, :count).by(-1)
    end

    it 'redirects to the games list' do
      game = Game.create! valid_attributes
      delete :destroy, params: { id: game.to_param }
      expect(response).to redirect_to(games_url)
    end
  end
end
