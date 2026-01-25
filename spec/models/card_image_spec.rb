require 'rails_helper'

RSpec.describe CardImage, type: :model do
  describe 'associations' do
    it { should belong_to(:card) }
  end

  describe '#image_file=' do
    let(:card_image) { build(:card_image) }
    let(:uploaded_file) { double(read: 'image data', content_type: 'image/jpeg', original_filename: 'test.jpg') }

    it 'sets image_data, content_type, and filename' do
      card_image.image_file = uploaded_file
      expect(card_image.image_data).to eq('image data')
      expect(card_image.content_type).to eq('image/jpeg')
      expect(card_image.filename).to eq('test.jpg')
    end
  end

  describe '#has_image?' do
    it 'returns true when image_data is present' do
      card_image = build(:card_image, image_data: 'data')
      expect(card_image.has_image?).to be true
    end

    it 'returns false when image_data is blank' do
      card_image = build(:card_image, image_data: nil)
      expect(card_image.has_image?).to be false
    end
  end
end
