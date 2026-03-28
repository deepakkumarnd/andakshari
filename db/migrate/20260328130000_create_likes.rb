class CreateLikes < ActiveRecord::Migration[8.0]
  def change
    create_table :likes do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :song, null: false, foreign_key: true
      t.timestamps
    end

    add_index :likes, [ :user_id, :song_id ], unique: true
    add_column :songs, :likes_count, :integer, default: 0, null: false
  end
end
