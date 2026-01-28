FactoryBot.define do
  factory :game_deck do
    association :game
    association :deck
  end
end
