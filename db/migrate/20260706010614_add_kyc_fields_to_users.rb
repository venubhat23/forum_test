class AddKycFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :gst_number, :string
    add_column :users, :pan_number, :string
    add_column :users, :aadhaar_number, :string
    add_column :users, :website, :string
    add_column :users, :address, :text
    add_column :users, :experience_years, :integer
    add_column :users, :date_of_birth, :date
    add_column :users, :membership_status, :integer, null: false, default: 0
    add_column :users, :renews_on, :date
    add_column :users, :business_category_id, :bigint
    add_index :users, :business_category_id
    add_column :users, :converted_at, :datetime
    add_column :users, :term_starts_on, :date
    add_column :users, :term_ends_on, :date
    add_column :users, :responsibilities, :text
    add_column :users, :membership_plan_id, :bigint
    add_index :users, :membership_plan_id
  end
end
