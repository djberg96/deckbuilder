class User < ApplicationRecord
  has_secure_password
  has_many :decks, dependent: :destroy

  has_many :user_groups, dependent: :destroy
  has_many :groups, :through => :user_groups

  validates :username,
    :length      => {:minimum => 3, :maximum => 16},
    :allow_blank => false,
    :uniqueness  => true

  validates :password, :confirmation => true

  def add_to_group(group)
    user_groups.create(:user => self, :group => group)
  end
end
