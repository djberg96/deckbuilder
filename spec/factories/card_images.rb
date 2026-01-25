FactoryBot.define do
  factory :card_image do
    association :card
    image_data { "fake image data" }
    content_type { "image/png" }
    filename { "test.png" }
  end
end
