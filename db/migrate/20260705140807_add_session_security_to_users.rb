class AddSessionSecurityToUsers < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :session_token, :string
    add_column :users, :suspended_at, :datetime

    User.reset_column_information
    User.find_each { |user| user.update_column(:session_token, SecureRandom.hex(32)) }

    change_column_null :users, :session_token, false
  end

  def down
    remove_column :users, :session_token
    remove_column :users, :suspended_at
  end
end
