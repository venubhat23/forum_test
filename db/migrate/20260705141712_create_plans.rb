class CreatePlans < ActiveRecord::Migration[8.0]
  def change
    create_table :plans do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0
      t.integer :billing_cycle, null: false, default: 0
      t.integer :member_limit
      t.text :features, array: true, null: false, default: []
      t.integer :trial_days, null: false, default: 14
      t.integer :status, null: false, default: 0
      t.integer :position, null: false, default: 0

      t.timestamps
    end
    add_index :plans, :key, unique: true
  end
end
