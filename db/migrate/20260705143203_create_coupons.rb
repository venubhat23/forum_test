class CreateCoupons < ActiveRecord::Migration[8.0]
  def change
    create_table :coupons do |t|
      t.string :code, null: false
      t.integer :discount_type, null: false, default: 0
      t.decimal :discount_value, precision: 10, scale: 2, null: false
      t.boolean :active, null: false, default: true
      t.date :expires_on
      t.integer :max_redemptions
      t.integer :times_redeemed, null: false, default: 0

      t.timestamps
    end
    add_index :coupons, :code, unique: true
  end
end
