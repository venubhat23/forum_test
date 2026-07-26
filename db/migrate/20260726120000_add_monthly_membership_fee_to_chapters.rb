class AddMonthlyMembershipFeeToChapters < ActiveRecord::Migration[8.0]
  def change
    add_column :chapters, :monthly_membership_fee, :decimal, precision: 10, scale: 2
  end
end
