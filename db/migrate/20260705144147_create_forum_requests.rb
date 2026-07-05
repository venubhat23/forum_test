class CreateForumRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :forum_requests do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :company_name, null: false
      t.text :message
      t.integer :status, null: false, default: 0
      t.text :review_note
      t.references :reviewed_by, foreign_key: { to_table: :users }
      t.references :forum, foreign_key: true

      t.timestamps
    end
  end
end
