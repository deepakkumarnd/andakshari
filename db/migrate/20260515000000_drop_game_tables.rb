class DropGameTables < ActiveRecord::Migration[8.0]
  def up
    drop_table :game_participants
    drop_table :game_rooms
  end

  def down
    create_table :game_rooms, id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, default: "waiting", null: false
      t.timestamps
    end

    create_table :game_participants do |t|
      t.references :game_room, type: :uuid, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false
      t.timestamps
    end
    add_index :game_participants, %i[game_room_id user_id], unique: true
  end
end
