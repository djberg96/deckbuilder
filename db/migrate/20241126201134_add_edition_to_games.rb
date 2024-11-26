class AddEditionToGames < ActiveRecord::Migration[7.2]
  def change
    add_column :games, :edition, :string
  end
end
