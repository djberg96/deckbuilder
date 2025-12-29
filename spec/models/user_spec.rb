require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:decks) }
    it { should have_many(:user_groups) }
    it { should have_many(:groups).through(:user_groups) }
  end

  describe 'validations' do
    it { should validate_length_of(:username).is_at_least(3).is_at_most(16) }

    it 'validates username cannot be blank' do
      user = build(:user, username: '')
      expect(user).not_to be_valid
      expect(user.errors[:username]).to be_present
    end

    context 'uniqueness validation' do
      subject { build(:user) }
      it { should validate_uniqueness_of(:username) }
    end

    it { should have_secure_password }
    it { should validate_confirmation_of(:password) }
  end

  describe '#add_to_group' do
    let(:user) { create(:user) }
    let(:group) { create(:group) }

    it 'adds the user to a group' do
      expect { user.add_to_group(group) }.to change(UserGroup, :count).by(1)
    end

    it 'creates a user_group association' do
      user.add_to_group(group)
      expect(user.groups).to include(group)
    end
  end
end
