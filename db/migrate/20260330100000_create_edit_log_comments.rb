class CreateEditLogComments < ActiveRecord::Migration[8.0]
  def change
    create_table :edit_log_comments do |t|
      t.belongs_to :edit_log, null: false, foreign_key: true
      t.belongs_to :user,     null: false, foreign_key: true
      t.text :body, null: false
      t.timestamps
    end
  end
end
