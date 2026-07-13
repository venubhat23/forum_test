class CreateLeads < ActiveRecord::Migration[8.0]
  def change
    create_table :leads do |t|
      t.references :forum, null: false, foreign_key: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.references :accepted_by, foreign_key: { to_table: :users }

      t.string :prospect_name, null: false
      t.string :prospect_phone
      t.string :prospect_email
      t.string :business_name
      t.string :business_category
      t.text :requirement
      t.text :notes

      t.integer :stage, null: false, default: 0
      t.datetime :accepted_at

      t.decimal :thanksgiving_amount, precision: 10, scale: 2
      t.text :thanksgiving_notes
      t.datetime :thanksgiving_given_at

      t.timestamps
    end

    create_table :lead_taggings do |t|
      t.references :lead, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    add_index :lead_taggings, [ :lead_id, :user_id ], unique: true
  end
end
