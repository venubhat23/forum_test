class AddMembershipYearToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :membership_year, :integer
  end
end
