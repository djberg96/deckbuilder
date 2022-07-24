class User < ApplicationRecord
  has_secure_password
  has_many :decks

  has_many :groups_users
  has_many :groups, :through => :groups_users

  validates :username, :length => {:minimum => 3, :maximum => 16}, :allow_blank => false
  validates :password, :confirmation => true

  def add_to_group(group)
    groups_users.create(:user => self, :group => group)
  end
end
