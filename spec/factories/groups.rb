FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "Group #{n}" }
    description { Faker::Lorem.sentence }
    private { false }
  end
end
