require 'rails_helper'

RSpec.describe Group, type: :model do
  describe 'associations' do
    it { should have_many(:user_groups) }
    it { should have_many(:users).through(:user_groups) }
  end

  describe 'validations' do
    it { should validate_length_of(:name).is_at_least(2).is_at_most(32) }

    it 'validates name cannot be blank' do
      group = build(:group, name: '')
      expect(group).not_to be_valid
      expect(group.errors[:name]).to be_present
    end
  end

  describe '#add_user' do
    let(:group) { create(:group) }
    let(:user) { create(:user) }

    it 'adds a user to the group' do
      expect { group.add_user(user) }.to change(UserGroup, :count).by(1)
    end

    it 'creates a user_group association' do
      group.add_user(user)
      expect(group.users).to include(user)
    end
  end
end
