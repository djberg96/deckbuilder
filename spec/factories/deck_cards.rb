FactoryBot.define do
  factory :deck_card do
    quantity { 1 }
    association :deck
    association :card
  end
end
