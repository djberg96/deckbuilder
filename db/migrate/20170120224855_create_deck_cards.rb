class CreateDeckCards < ActiveRecord::Migration[6.1]
  def change
    create_join_table :cards, :decks do |t|
      t.integer :quantity
      t.index [:card_id, :deck_id], :unique => true, :name => 'cards_decks_index'
    end
  end
end
