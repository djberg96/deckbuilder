class User < ApplicationRecord
  has_secure_password
  has_many :decks
  has_many :user_groups
  has_many :groups, :through => :user_groups
end
