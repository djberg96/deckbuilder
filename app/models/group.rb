class Group < ApplicationRecord
  has_many :user_groups
  has_many :users, :through => :user_groups

  def add_user(user)
    user_groups.create(:user => user, :group => self)
  end
end
