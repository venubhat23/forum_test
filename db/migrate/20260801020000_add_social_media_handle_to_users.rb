class AddSocialMediaHandleToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :social_media_handle, :string
  end
end
