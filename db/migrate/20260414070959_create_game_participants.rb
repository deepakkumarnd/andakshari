class CreateGameParticipants < ActiveRecord::Migration[8.0]
  def change
    create_table :game_participants do |t|
      t.references :game_room, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false

      t.timestamps
    end

    add_index :game_participants, [ :game_room_id, :user_id ], unique: true
  end
end
