class AddForeignKeyToCards < ActiveRecord::Migration[7.2]
  def change
    add_foreign_key :cards, :games
  end
end
