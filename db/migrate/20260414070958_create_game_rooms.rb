class CreateGameRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :game_rooms, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false, default: "waiting"

      t.timestamps
    end
  end
end
