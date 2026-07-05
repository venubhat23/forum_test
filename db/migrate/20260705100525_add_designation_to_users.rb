class AddDesignationToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :designation, :string
  end
end
