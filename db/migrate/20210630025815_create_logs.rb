class CreateLogs < ActiveRecord::Migration[6.1]
  def change
    create_table :logs do |t|
      t.string :severity
      t.string :message
      t.timestamp :timestamp
    end
  end
end
