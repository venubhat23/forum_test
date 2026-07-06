class CreateMembershipPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :membership_plans do |t|
      t.references :forum, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :cycle, null: false, default: 0
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0
      t.text :renewal_rules

      t.timestamps
    end

    add_foreign_key :users, :membership_plans
  end
end
