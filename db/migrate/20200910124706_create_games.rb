class CreateGames < ActiveRecord::Migration[6.1]
  def change
    create_table :games do |t|
      t.string :name
      t.text :description
      t.integer :maximum_cards_per_deck
      t.integer :minimum_cards_per_deck
      t.integer :maximum_individual_cards
      t.json :data
      t.timestamps
    end
  end
end
