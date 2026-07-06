class CreateExpenses < ActiveRecord::Migration[8.0]
  def change
    create_table :expenses do |t|
      t.references :forum, null: false, foreign_key: true
      t.string :category, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.date :incurred_on, null: false
      t.text :notes

      t.timestamps
    end
  end
end
