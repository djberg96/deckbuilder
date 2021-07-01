class Group < ApplicationRecord
  has_many :users, :through => :user_group
end
