class CreateGameDecks < ActiveRecord::Migration
  def change
    create_table :game_decks do |t|
      t.references :game, foreign_key: true
      t.references :deck, foreign_key: true
      t.integer :quantity
      t.index [:game_id, :deck_id], :unique => true
    end
  end
end
