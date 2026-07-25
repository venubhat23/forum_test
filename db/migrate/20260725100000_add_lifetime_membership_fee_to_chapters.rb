class AddLifetimeMembershipFeeToChapters < ActiveRecord::Migration[8.0]
  def change
    add_column :chapters, :lifetime_membership_fee, :decimal, precision: 10, scale: 2
  end
end
