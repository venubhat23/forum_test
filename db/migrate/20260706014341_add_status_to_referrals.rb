class AddStatusToReferrals < ActiveRecord::Migration[8.0]
  def change
    add_column :referrals, :status, :integer, null: false, default: 0
  end
end
