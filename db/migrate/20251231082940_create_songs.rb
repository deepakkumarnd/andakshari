class CreateSongs < ActiveRecord::Migration[8.0]
  def change
    create_table :songs do |t|
      t.text :pallavi
      t.text :lyrics
      t.text :movie
      t.integer :year
      t.references :letter, null: false, foreign_key: true

      t.timestamps
    end
  end
end
