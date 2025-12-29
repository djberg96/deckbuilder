require 'rails_helper'

RSpec.describe GroupsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { { name: 'Test Group', description: 'A test group', private: false } }
  let(:invalid_attributes) { { name: 'A' } }

  before do
    session[:user_id] = user.id
  end

  describe 'GET #index' do
    it 'returns a success response' do
      Group.create! valid_attributes
      get :index
      expect(response).to be_successful
    end

    it 'assigns all groups as @groups' do
      group = Group.create! valid_attributes
      get :index
      expect(assigns(:groups)).to eq([group])
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      group = Group.create! valid_attributes
      get :show, params: { id: group.to_param }
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
      group = Group.create! valid_attributes
      get :edit, params: { id: group.to_param }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Group' do
        expect {
          post :create, params: { group: valid_attributes }
        }.to change(Group, :count).by(1)
      end

      it 'redirects to the created group' do
        post :create, params: { group: valid_attributes }
        expect(response).to redirect_to(Group.last)
      end
    end

    context 'with invalid params' do
      it 'returns a success response (i.e. to display the new template)' do
        post :create, params: { group: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) { { name: 'Updated Group' } }

      it 'updates the requested group' do
        group = Group.create! valid_attributes
        put :update, params: { id: group.to_param, group: new_attributes }
        group.reload
        expect(group.name).to eq('Updated Group')
      end

      it 'redirects to the group' do
        group = Group.create! valid_attributes
        put :update, params: { id: group.to_param, group: valid_attributes }
        expect(response).to redirect_to(group)
      end
    end

    context 'with invalid params' do
      it 'returns a success response (i.e. to display the edit template)' do
        group = Group.create! valid_attributes
        put :update, params: { id: group.to_param, group: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested group' do
      group = Group.create! valid_attributes
      expect {
        delete :destroy, params: { id: group.to_param }
      }.to change(Group, :count).by(-1)
    end

    it 'redirects to the groups list' do
      group = Group.create! valid_attributes
      delete :destroy, params: { id: group.to_param }
      expect(response).to redirect_to(groups_url)
    end
  end
end
