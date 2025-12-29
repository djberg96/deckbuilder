FactoryBot.define do
  factory :user_group do
    association :user
    association :group
  end
end
