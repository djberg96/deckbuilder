class CardImage < ApplicationRecord
  belongs_to :card

  attr_accessor :upload

  before_validation :populate_from_upload

  validates :filename, presence: true
  validates :content_type, presence: true
  validates :data, presence: true

  validate :data_size_within_limit

  MAX_SIZE_BYTES = 64 * 1024 # 64 KB

  def populate_from_upload
    return unless upload
    self.filename = upload.original_filename if upload.respond_to?(:original_filename)
    self.content_type = upload.content_type if upload.respond_to?(:content_type)
    self.data = upload.read if upload.respond_to?(:read)
  end

  def data_size_within_limit
    return if data.nil?
    if data.to_s.bytesize > MAX_SIZE_BYTES
      errors.add(:data, "must be #{MAX_SIZE_BYTES} bytes or less")
    end
  end
end
