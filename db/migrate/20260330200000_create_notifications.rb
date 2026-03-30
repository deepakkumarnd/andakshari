class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :notification_type, null: false
      t.text   :message,           null: false
      t.string :url,               null: false
      t.timestamps
    end

    add_index :notifications, [ :user_id, :created_at ]
  end
end
