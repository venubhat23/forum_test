class CreateSupportTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :support_tickets do |t|
      t.references :forum, foreign_key: true
      t.references :raised_by, null: false, foreign_key: { to_table: :users }
      t.string :subject, null: false
      t.text :body, null: false
      t.integer :status, null: false, default: 0
      t.integer :priority, null: false, default: 1

      t.timestamps
    end
  end
end
