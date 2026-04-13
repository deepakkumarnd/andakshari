class AddUsernameToUsers < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :username, :string

    User.find_each do |user|
      user.update_column(:username, User.generate_username(user.role))
    end

    change_column_null :users, :username, false
    add_index :users, :username, unique: true
  end

  def down
    remove_index :users, :username
    remove_column :users, :username
  end
end
