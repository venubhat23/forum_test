class AddRoleAndForumToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :role, :integer, null: false, default: 4
    add_reference :users, :forum, null: true, foreign_key: true
    add_reference :users, :chapter, null: true, foreign_key: true
  end
end
