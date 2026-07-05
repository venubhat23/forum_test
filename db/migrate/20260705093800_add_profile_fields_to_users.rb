class AddProfileFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :full_name, :string
    add_column :users, :phone, :string
    add_column :users, :business_name, :string
    add_column :users, :business_category, :string
    add_column :users, :speciality, :string
    add_column :users, :nature_of_business, :string
    add_column :users, :invited_by_id, :bigint

    add_index :users, :invited_by_id
    add_foreign_key :users, :users, column: :invited_by_id
  end
end
