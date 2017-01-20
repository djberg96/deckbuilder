class DeckCards < ActiveRecord::Migration[5.0]
  def change
    create_join_table :decks, :cards, :table_name => :deck_cards
  end
end
