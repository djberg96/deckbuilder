FactoryBot.define do
  factory :deck do
    sequence(:name) { |n| "Deck #{n}" }
    description { Faker::Lorem.sentence }
    private { false }
    association :user

    transient do
      game { nil }
    end

    after(:build) do |deck, evaluator|
      if deck.new_record? && deck.game.nil?
        game_to_use = evaluator.game || build(:game)
        deck.build_game_deck(game: game_to_use)
      end
    end

    trait :with_game do
      # This trait is now redundant but kept for backward compatibility
      # The factory now always creates a game_deck by default
    end
  end
end
