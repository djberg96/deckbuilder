FactoryBot.define do
  factory :deck do
    sequence(:name) { |n| "Deck #{n}" }
    description { Faker::Lorem.sentence }
    private { false }
    association :user

    trait :with_game do
      transient do
        game { nil }
      end

      after(:create) do |deck, evaluator|
        game = evaluator.game || create(:game)
        create(:game_deck, deck: deck, game: game) unless deck.game_deck
      end
    end
  end
end
