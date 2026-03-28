class AddStartLetterToSongs < ActiveRecord::Migration[8.0]
  def change
    add_column :songs, :start_letter, :string
    add_index :songs, :start_letter
  end
end
