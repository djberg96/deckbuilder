class AddForeignKeyToDecks < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :decks, :users
  end
end
