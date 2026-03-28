class AddIndexOnSongsYear < ActiveRecord::Migration[8.0]
  def change
    add_index :songs, :year
  end
end
