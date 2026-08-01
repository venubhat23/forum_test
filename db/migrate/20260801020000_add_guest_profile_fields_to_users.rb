class AddGuestProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :profile_token, :string
    add_column :users, :social_media_handle, :string
    add_column :users, :profile_submitted_at, :datetime
    add_index :users, :profile_token, unique: true
  end
end
