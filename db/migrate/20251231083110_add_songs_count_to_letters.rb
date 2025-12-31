class AddSongsCountToLetters < ActiveRecord::Migration[8.0]
  def change
    add_column :letters, :songs_count, :integer
  end
end
