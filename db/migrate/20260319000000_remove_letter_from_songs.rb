class RemoveLetterFromSongs < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :songs, :letters
    remove_index :songs, :letter_id
    remove_column :songs, :letter_id, :bigint
    remove_column :letters, :songs_count, :integer
  end
end
