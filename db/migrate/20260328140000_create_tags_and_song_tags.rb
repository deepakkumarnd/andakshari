class CreateTagsAndSongTags < ActiveRecord::Migration[8.0]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_index :tags, :name, unique: true

    create_table :song_tags do |t|
      t.belongs_to :song, null: false, foreign_key: true
      t.belongs_to :tag, null: false, foreign_key: true
      t.timestamps
    end

    add_index :song_tags, [ :song_id, :tag_id ], unique: true
  end
end
