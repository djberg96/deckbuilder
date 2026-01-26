class CreateCardImages < ActiveRecord::Migration[7.0]
  def change
    create_table :card_images do |t|
      t.references :card, null: false, foreign_key: true
      t.string :filename
      t.string :content_type
      t.binary :data

      t.timestamps
    end
  end
end
