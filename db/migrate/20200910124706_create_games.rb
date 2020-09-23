class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.string :name
      t.text :description
      t.integer :maximum_cards_per_deck
      t.integer :minimum_cards_per_deck
      t.timestamps
    end
  end
end
