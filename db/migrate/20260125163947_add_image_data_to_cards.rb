class AddImageDataToCards < ActiveRecord::Migration[7.2]
  def change
    add_column :cards, :image_data, :binary
  end
end
