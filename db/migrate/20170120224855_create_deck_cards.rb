class CreateDeckCards < ActiveRecord::Migration[6.1]
  def change
    create_table :deck_cards do |t|
      t.references :card, foreign_key: true
      t.references :deck, foreign_key: true
      t.integer :quantity
      t.index [:card_id, :deck_id], :unique => true
    end
  end
end
