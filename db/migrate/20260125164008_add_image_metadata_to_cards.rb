class AddImageMetadataToCards < ActiveRecord::Migration[7.2]
  def change
    add_column :cards, :image_content_type, :string
    add_column :cards, :image_filename, :string
  end
end
