class User < ApplicationRecord
  has_secure_password
  has_many :decks
  has_many :groups, :through => :user_group
end
