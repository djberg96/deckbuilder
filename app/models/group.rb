class Group < ApplicationRecord
  has_many :user_groups, dependent: :destroy
  has_many :users, :through => :user_groups

  validates :name, :length => {:minimum => 2, :maximum => 32}, :allow_blank => false

  def add_user(user)
    user_groups.create(:user => user, :group => self)
  end
end
