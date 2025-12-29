FactoryBot.define do
  factory :game do
    sequence(:name) { |n| "Game #{n}" }
    sequence(:edition) { |n| "Edition #{n}" }
    description { Faker::Lorem.sentence }
    minimum_cards_per_deck { 40 }
    maximum_cards_per_deck { 60 }
    maximum_individual_cards { 4 }
  end
end
