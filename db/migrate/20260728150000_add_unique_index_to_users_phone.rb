class AddUniqueIndexToUsersPhone < ActiveRecord::Migration[8.0]
  def change
    add_index :users, "lower(phone)", unique: true, name: "index_users_on_lower_phone", where: "phone IS NOT NULL AND phone <> ''"
  end
end
