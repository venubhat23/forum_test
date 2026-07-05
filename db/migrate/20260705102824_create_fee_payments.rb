class CreateFeePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :fee_payments do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :fee_type, null: false
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :status, null: false, default: 0
      t.date :due_date
      t.date :paid_on

      t.timestamps
    end
  end
end
