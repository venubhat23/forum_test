class CreateMembershipApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :membership_applications do |t|
      t.references :forum, null: false, foreign_key: true
      t.references :chapter, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :business_name
      t.string :nature_of_business
      t.integer :status, null: false, default: 0
      t.text :review_note
      t.references :reviewed_by, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
