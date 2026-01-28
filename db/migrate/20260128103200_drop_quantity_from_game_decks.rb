class DropQuantityFromGameDecks < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    # Remove malformed rows first (safety)
    reversible do |dir|
      dir.up do
        execute <<-SQL.squish
          DELETE FROM game_decks WHERE deck_id IS NULL;
        SQL
      end
    end

    if column_exists?(:game_decks, :quantity)
      remove_column :game_decks, :quantity
    end
  end

  def down
    unless column_exists?(:game_decks, :quantity)
      add_column :game_decks, :quantity, :integer
    end
  end
end
