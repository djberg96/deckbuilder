class CreateCardImages < ActiveRecord::Migration[7.2]
  def change
    create_table :card_images do |t|
      t.references :card, null: false, foreign_key: true
      t.binary :image_data
      t.string :content_type
      t.string :filename
      t.timestamps
    end
  end
end
