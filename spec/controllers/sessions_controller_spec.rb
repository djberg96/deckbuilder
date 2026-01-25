require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:user) { create(:user, username: 'testuser', password: 'password123') }

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end

    context 'when user exists' do
      it 'redirects to decks_url with welcome message' do
        get :new, params: { username: user.username }
        expect(response).to redirect_to(decks_url)
        expect(flash[:alert]).to include("Welcome to the Deckbuilder #{user.username}")
      end
    end

    context 'when user does not exist' do
      it 'returns a success response' do
        get :new, params: { username: 'nonexistent' }
        expect(response).to be_successful
      end
    end
  end

  describe 'POST #create' do
    context 'with valid credentials' do
      it 'sets the user_id in session' do
        post :create, params: { username: user.username, password: 'password123' }
        expect(session[:user_id]).to eq(user.id)
      end

      it 'redirects to decks_url' do
        post :create, params: { username: user.username, password: 'password123' }
        expect(response).to redirect_to(decks_url)
      end
    end

    context 'with invalid credentials' do
      it 'does not set the user_id in session' do
        post :create, params: { username: user.username, password: 'wrongpassword' }
        expect(session[:user_id]).to be_nil
      end

      it 'redirects to login_url with alert' do
        post :create, params: { username: user.username, password: 'wrongpassword' }
        expect(response).to redirect_to(login_url)
        expect(flash[:alert]).to eq('Invalid username/password combination')
      end
    end

    context 'with non-existent user' do
      it 'redirects to login_url with alert' do
        post :create, params: { username: 'nonexistent', password: 'password' }
        expect(response).to redirect_to(login_url)
        expect(flash[:alert]).to eq('Invalid username/password combination')
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      session[:user_id] = user.id
    end

    it 'clears the user_id from session' do
      delete :destroy
      expect(session[:user_id]).to be_nil
    end

    it 'redirects to login_url with notice' do
      delete :destroy
      expect(response).to redirect_to(login_url)
      expect(flash[:notice]).to eq('Logged out')
    end
  end
end
