class AddPrivateFieldToDecks < ActiveRecord::Migration
  def change
    add_column :decks, :private, :boolean, :default => false
  end
end
