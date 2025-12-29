FactoryBot.define do
  factory :card do
    sequence(:name) { |n| "Card #{n}" }
    description { Faker::Lorem.sentence }
    data { { type: "Creature", cost: 3 } }
    association :game
  end
end
