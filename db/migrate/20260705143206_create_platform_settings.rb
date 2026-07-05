class CreatePlatformSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :platform_settings do |t|
      t.string :site_name, null: false, default: "Krama Consultancy"
      t.string :support_email
      t.string :currency, null: false, default: "INR"
      t.string :invoice_prefix, null: false, default: "INV"
      t.decimal :tax_percent, precision: 5, scale: 2, null: false, default: 0
      t.references :default_plan, foreign_key: { to_table: :plans }

      t.timestamps
    end
  end
end
