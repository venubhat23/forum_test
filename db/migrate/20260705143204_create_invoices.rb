class CreateInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :invoices do |t|
      t.references :forum, null: false, foreign_key: true
      t.references :plan, foreign_key: true
      t.references :coupon, foreign_key: true
      t.string :invoice_number, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, null: false, default: "INR"
      t.integer :status, null: false, default: 0
      t.date :due_date, null: false
      t.date :paid_on
      t.text :description

      t.timestamps
    end
    add_index :invoices, :invoice_number, unique: true
  end
end
