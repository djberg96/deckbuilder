require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) {
    {
      username: 'newuser',
      first_name: 'John',
      last_name: 'Doe',
      password: 'password123',
      password_confirmation: 'password123'
    }
  }
  let(:invalid_attributes) { { username: 'ab', password: 'pass' } }

  describe 'GET #index' do
    before do
      session[:user_id] = user.id
    end

    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns non-private users as @users' do
      public_user = create(:user, private: false)
      private_user = create(:user, private: true)
      get :index
      expect(assigns(:users)).to include(public_user)
      expect(assigns(:users)).not_to include(private_user)
    end
  end

  describe 'GET #show' do
    before do
      session[:user_id] = user.id
    end

    it 'returns a success response' do
      get :show, params: { id: user.to_param }
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
    before do
      session[:user_id] = user.id
    end

    it 'returns a success response' do
      get :edit, params: { id: user.to_param }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'does not create a User without authorization' do
        expect {
          post :create, params: { user: valid_attributes }
        }.not_to change(User, :count)
      end

      it 'redirects to login (requires authentication)' do
        post :create, params: { user: valid_attributes }
        # Since user is not logged in, gets redirected to login
        expect(response).to redirect_to(login_url)
      end
    end

    context 'with invalid params' do
      it 'redirects to login without creating user' do
        expect {
          post :create, params: { user: invalid_attributes }
        }.not_to change(User, :count)
        expect(response).to redirect_to(login_url)
      end
    end
  end

  describe 'PUT #update' do
    before do
      session[:user_id] = user.id
    end

    context 'with valid params' do
      let(:new_attributes) { { first_name: 'Jane' } }

      it 'updates the requested user' do
        put :update, params: { id: user.to_param, user: new_attributes }
        user.reload
        expect(user.first_name).to eq('Jane')
      end

      it 'redirects to the user' do
        put :update, params: { id: user.to_param, user: new_attributes }
        expect(response).to redirect_to(user)
      end
    end

    context 'with invalid params' do
      it 'returns a success response (i.e. to display the edit template)' do
        put :update, params: { id: user.to_param, user: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      session[:user_id] = user.id
    end

    it 'destroys the requested user' do
      user_to_delete = create(:user)
      expect {
        delete :destroy, params: { id: user_to_delete.to_param }
      }.to change(User, :count).by(-1)
    end

    it 'redirects to the users list' do
      user_to_delete = create(:user)
      delete :destroy, params: { id: user_to_delete.to_param }
      expect(response).to redirect_to(users_url)
    end
  end

  describe 'authorization' do
    it 'requires login for index' do
      get :index
      expect(response).to redirect_to(login_url)
    end

    it 'requires login for show' do
      get :show, params: { id: user.to_param }
      expect(response).to redirect_to(login_url)
    end

    it 'does not require login for new' do
      get :new
      expect(response).to be_successful
    end
  end
end
