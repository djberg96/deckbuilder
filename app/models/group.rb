class Group < ApplicationRecord
  has_many :groups_users
  has_many :users, :through => :groups_users

  validates :name, :length => {:minimum => 2, :maximum => 32}, :allow_blank => false

  def add_user(user)
    groups_users.create(:user => user, :group => self)
  end
end
