class AddGameIdToCards < ActiveRecord::Migration
  def change
    add_column :cards, :game_id, :integer
  end
end
