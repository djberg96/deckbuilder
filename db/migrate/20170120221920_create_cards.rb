class CreateCards < ActiveRecord::Migration[6.1]
  def change
    create_table :cards do |t|
      t.string :name
      t.text :description
      t.json :data

      t.timestamps
    end
  end
end
