FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    password { "password123" }
    password_confirmation { "password123" }
  end
end
