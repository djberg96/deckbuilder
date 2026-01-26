require 'rails_helper'

RSpec.describe CardImage, type: :model do
  let(:card) { create(:card) }

  it 'associates with a card' do
    img = CardImage.new(card: card)
    expect(img.card).to eq card
  end

  it 'is valid with an upload under 64 KB' do
    upload = fixture_file_upload(Rails.root.join('spec/fixtures/small.png'), 'image/png')
    img = CardImage.new(card: card, upload: upload)
    expect(img).to be_valid
  end

  it 'is invalid with data larger than 64 KB' do
    # Create a fake upload object with large payload
    large = StringIO.new('a' * (64 * 1024 + 1))
    # define file-like methods on the StringIO instance
    def large.original_filename; 'big.png'; end
    def large.content_type; 'image/png'; end

    img = CardImage.new(card: card, upload: large)
    img.validate
    expect(img.errors[:data].join).to match(/#{CardImage::MAX_SIZE_BYTES}/)
  end
end
