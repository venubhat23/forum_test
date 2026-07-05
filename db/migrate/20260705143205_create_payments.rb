class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.references :invoice, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :payment_method, null: false, default: 0
      t.date :paid_on, null: false
      t.string :reference_number
      t.references :recorded_by, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
