class CreateGameDecks < ActiveRecord::Migration[6.1]
  def change
    create_join_table :decks, :games do |t|
      t.integer :quantity
      t.index [:deck_id, :game_id], :unique => true, :name => 'decks_games_index'
    end
  end
end
