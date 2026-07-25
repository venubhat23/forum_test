class AddBillingSettingsToPlatformSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :platform_settings, :terms_and_conditions, :text
    add_column :platform_settings, :bank_name, :string
    add_column :platform_settings, :bank_account_holder, :string
    add_column :platform_settings, :bank_account_number, :string
    add_column :platform_settings, :bank_ifsc, :string
    add_column :platform_settings, :bank_branch, :string
    add_column :platform_settings, :upi_id, :string
  end
end
