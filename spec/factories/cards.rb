FactoryBot.define do
  factory :card do
    sequence(:name) { |n| "Card #{n}" }
    description { Faker::Lorem.sentence }
    data { { type: "Creature", cost: 3 } }
    association :game

    trait :with_image do
      after(:create) do |card|
        create(:card_image, card: card)
      end
    end
  end
end
