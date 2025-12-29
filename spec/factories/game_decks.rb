FactoryBot.define do
  factory :game_deck do
    quantity { 1 }
    association :game
    association :deck
  end
end
