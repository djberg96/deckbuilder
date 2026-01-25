class CardImage < ApplicationRecord
  belongs_to :card

  attr_accessor :image_file

  def image_file=(uploaded_file)
    if uploaded_file.present?
      self.image_data = uploaded_file.read
      self.content_type = uploaded_file.content_type
      self.filename = uploaded_file.original_filename
    end
  end

  def has_image?
    image_data.present?
  end
end
