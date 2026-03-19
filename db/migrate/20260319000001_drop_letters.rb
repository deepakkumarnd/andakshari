class DropLetters < ActiveRecord::Migration[8.0]
  def change
    drop_table :letters
  end
end
