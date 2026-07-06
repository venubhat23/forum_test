class CreateOfficeDarshans < ActiveRecord::Migration[8.0]
  def change
    create_table :office_darshans do |t|
      t.references :forum, null: false, foreign_key: true
      t.references :member, null: false, foreign_key: { to_table: :users }
      t.date :visit_date, null: false
      t.integer :status, null: false, default: 0
      t.text :notes

      t.timestamps
    end
  end
end
