class AddUserIdColumnToDecks < ActiveRecord::Migration[6.1]
  def change
    add_column :decks, :user_id, :integer
  end
end
