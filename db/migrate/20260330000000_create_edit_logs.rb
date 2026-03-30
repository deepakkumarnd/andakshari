class CreateEditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :edit_logs do |t|
      t.belongs_to :song, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true
      t.string  :field,     null: false
      t.text    :old_value
      t.text    :new_value, null: false
      t.string  :status,    null: false, default: "pending"
      t.timestamps
    end

    add_index :edit_logs, [ :song_id, :status ]
    add_index :edit_logs, [ :song_id, :user_id, :field ]
  end
end
