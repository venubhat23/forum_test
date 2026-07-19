class AddConversionFieldsToUsersAndFeePayments < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :service_area, :string
    add_column :users, :capacity, :string
    add_column :users, :lifetime_member, :boolean, default: false, null: false

    add_column :fee_payments, :duration_years, :integer
    add_column :fee_payments, :lifetime, :boolean, default: false, null: false
  end
end
